#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <libproc.h>
#include <mach/mach_time.h>
#include <objc/message.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "apps.h"
#include "temps.h"

// Metal, used once to read how much unified memory the GPU may use.
typedef struct objc_object* id;
id MTLCreateSystemDefaultDevice(void);

// Must match the number of gpu.popup.proc.N items in items/gpu.sh.
#define GPU_TOP_PROCS 8
#define GPU_MAX_PROCS 512
#define GPU_PROC_NAME_LEN 24
#define GPU_PROC_ELLIPSIS "..."

struct gpu_proc {
  pid_t pid;
  uint64_t gpu_ns;
  double percent;
  char name[GPU_PROC_NAME_LEN + sizeof(GPU_PROC_ELLIPSIS)];
};

struct gpu_sample {
  int utilization;
  int renderer;
  int tiler;
  uint64_t memory_in_use;
  double temperature;
};

struct gpu {
  mach_timebase_info_data_t timebase;
  uint64_t memory_limit;

  // Accumulated GPU time per process from the previous update.
  struct gpu_proc procs[GPU_MAX_PROCS];
  uint32_t proc_count;
  uint64_t procs_timestamp;
  bool has_prev_procs;

  char command[2048];
};

static inline void gpu_init(struct gpu* gpu) {
  gpu->proc_count = 0;
  gpu->procs_timestamp = 0;
  gpu->has_prev_procs = false;
  mach_timebase_info(&gpu->timebase);

  // The GPU shares system RAM, macOS caps its working set below the total.
  gpu->memory_limit = 0;
  id device = MTLCreateSystemDefaultDevice();
  if (device) {
    gpu->memory_limit = ((uint64_t (*)(id, SEL))objc_msgSend)(
      device, sel_registerName("recommendedMaxWorkingSetSize"));
  }
  snprintf(gpu->command, sizeof(gpu->command), "");
}

static inline uint64_t gpu_now_ns(struct gpu* gpu) {
  return mach_absolute_time() * gpu->timebase.numer / gpu->timebase.denom;
}

static inline int gpu_dict_int(CFDictionaryRef dict, CFStringRef key) {
  CFNumberRef value = CFDictionaryGetValue(dict, key);
  int number;
  if (!value || !CFNumberGetValue(value, kCFNumberIntType, &number)) return -1;
  return number;
}

static inline void gpu_read_statistics(io_registry_entry_t service,
                                       struct gpu_sample* sample) {
  CFDictionaryRef stats = IORegistryEntryCreateCFProperty(
    service, CFSTR("PerformanceStatistics"), kCFAllocatorDefault, 0);
  if (!stats) return;

  int utilization = gpu_dict_int(stats, CFSTR("Device Utilization %"));
  if (utilization > sample->utilization) {
    sample->utilization = utilization;
    sample->renderer = gpu_dict_int(stats, CFSTR("Renderer Utilization %"));
    sample->tiler = gpu_dict_int(stats, CFSTR("Tiler Utilization %"));

    CFNumberRef memory = CFDictionaryGetValue(stats,
                                              CFSTR("In use system memory"));
    int64_t bytes;
    if (memory && CFNumberGetValue(memory, kCFNumberSInt64Type, &bytes)) {
      sample->memory_in_use = (uint64_t)bytes;
    }
  }
  CFRelease(stats);
}

static inline struct gpu_proc* gpu_find_proc(struct gpu_proc* procs,
                                             uint32_t count,
                                             pid_t pid) {
  for (uint32_t i = 0; i < count; i++) {
    if (procs[i].pid == pid) return &procs[i];
  }
  return NULL;
}

// Adds a GPU user client's accumulated GPU time to its owning process.
static inline void gpu_read_client(io_registry_entry_t client,
                                   struct gpu_proc* procs,
                                   uint32_t* count) {
  CFStringRef creator = IORegistryEntryCreateCFProperty(
    client, CFSTR("IOUserClientCreator"), kCFAllocatorDefault, 0);
  if (!creator) return;

  // The creator looks like "pid 1234, kitty".
  char creator_str[64];
  pid_t pid = -1;
  char fallback_name[32] = "";
  if (CFStringGetCString(creator, creator_str, sizeof(creator_str),
                         kCFStringEncodingUTF8)) {
    sscanf(creator_str, "pid %d, %31[^\n]", &pid, fallback_name);
  }
  CFRelease(creator);
  if (pid <= 0) return;

  CFArrayRef usage = IORegistryEntryCreateCFProperty(
    client, CFSTR("AppUsage"), kCFAllocatorDefault, 0);
  if (!usage) return;

  uint64_t gpu_ns = 0;
  CFIndex usage_count = CFArrayGetCount(usage);
  for (CFIndex i = 0; i < usage_count; i++) {
    CFDictionaryRef entry = CFArrayGetValueAtIndex(usage, i);
    CFNumberRef time = CFDictionaryGetValue(entry,
                                            CFSTR("accumulatedGPUTime"));
    int64_t ns;
    if (time && CFNumberGetValue(time, kCFNumberSInt64Type, &ns) && ns > 0) {
      gpu_ns += (uint64_t)ns;
    }
  }
  CFRelease(usage);

  struct gpu_proc* proc = gpu_find_proc(procs, *count, pid);
  if (!proc) {
    if (*count >= GPU_MAX_PROCS) return;
    proc = &procs[(*count)++];
    proc->pid = pid;
    proc->gpu_ns = 0;
    proc->percent = 0;

    // Prefer the executable name, the creator name is cut at 16 characters.
    char path[PROC_PIDPATHINFO_MAXSIZE];
    const char* name = fallback_name;
    if (proc_pidpath(pid, path, sizeof(path)) > 0) {
      char* slash = strrchr(path, '/');
      name = slash ? slash + 1 : path;
    }

    // Drop quotes so the name can't break the sketchybar command.
    uint32_t caret = 0;
    for (uint32_t i = 0; name[i] != '\0' && caret < GPU_PROC_NAME_LEN; i++) {
      if (name[i] == '\'' || name[i] == '"') continue;
      proc->name[caret++] = name[i];
    }
    proc->name[caret] = '\0';
    if (strlen(name) > GPU_PROC_NAME_LEN) strcat(proc->name, GPU_PROC_ELLIPSIS);
  }
  proc->gpu_ns += gpu_ns;
}

// Reads device statistics and per-process GPU time from every IOAccelerator.
static inline bool gpu_read_accelerators(struct gpu_sample* sample,
                                         struct gpu_proc* procs,
                                         uint32_t* proc_count) {
  io_iterator_t iterator;
  if (IOServiceGetMatchingServices(kIOMainPortDefault,
                                   IOServiceMatching("IOAccelerator"),
                                   &iterator) != KERN_SUCCESS) {
    return false;
  }

  io_registry_entry_t service;
  while ((service = IOIteratorNext(iterator))) {
    gpu_read_statistics(service, sample);

    io_iterator_t clients;
    if (IORegistryEntryGetChildIterator(service, kIOServicePlane, &clients)
        == KERN_SUCCESS) {
      io_registry_entry_t client;
      while ((client = IOIteratorNext(clients))) {
        gpu_read_client(client, procs, proc_count);
        IOObjectRelease(client);
      }
      IOObjectRelease(clients);
    }
    IOObjectRelease(service);
  }
  IOObjectRelease(iterator);
  return sample->utilization >= 0;
}

static inline int gpu_compare_percent(const void* a, const void* b) {
  double left = ((const struct gpu_proc*)a)->percent;
  double right = ((const struct gpu_proc*)b)->percent;
  return (left < right) - (left > right);
}

// Appends popup rows with each process's share of GPU time since last update.
static inline void gpu_append_top_procs(struct gpu* gpu,
                                        struct gpu_proc* procs,
                                        uint32_t proc_count,
                                        uint64_t now,
                                        size_t* length) {
  uint64_t elapsed = now - gpu->procs_timestamp;
  if (!gpu->has_prev_procs || elapsed == 0) return;

  struct gpu_proc top[GPU_MAX_PROCS];
  uint32_t top_count = 0;
  for (uint32_t i = 0; i < proc_count; i++) {
    struct gpu_proc* prev = gpu_find_proc(gpu->procs,
                                          gpu->proc_count,
                                          procs[i].pid);
    if (!prev || procs[i].gpu_ns <= prev->gpu_ns) continue;

    top[top_count] = procs[i];
    top[top_count].percent = (double)(procs[i].gpu_ns - prev->gpu_ns)
                             / (double)elapsed * 100.;
    if (top[top_count].percent >= 0.1) top_count++;
  }
  qsort(top, top_count, sizeof(struct gpu_proc), gpu_compare_percent);

  for (uint32_t i = 0; i < GPU_TOP_PROCS; i++) {
    size_t remaining = sizeof(gpu->command) - *length;
    int written;
    if (i < top_count) {
      written = snprintf(gpu->command + *length, remaining,
                         " --set gpu.popup.proc.%u drawing=on "
                         "icon='%s' label='%.1f%%' label.color=%s",
                         i + 1,
                         top[i].name,
                         top[i].percent,
                         apps_color(top[i].percent, 10, 30, 70));
    } else if (i == 0) {
      written = snprintf(gpu->command + *length, remaining,
                         " --set gpu.popup.proc.1 drawing=on "
                         "icon='Nothing using the GPU' label='' ");
    } else {
      written = snprintf(gpu->command + *length, remaining,
                         " --set gpu.popup.proc.%u drawing=off", i + 1);
    }
    if (written < 0 || (size_t)written >= remaining) return;
    *length += written;
  }
}

static inline void gpu_update(struct gpu* gpu, struct temps* temps) {
  struct gpu_sample sample = { -1, -1, -1, 0, -1 };
  struct gpu_proc procs[GPU_MAX_PROCS];
  uint32_t proc_count = 0;
  uint64_t now = gpu_now_ns(gpu);

  if (!gpu_read_accelerators(&sample, procs, &proc_count)) {
    printf("Error: Could not read GPU utilization.\n");
    snprintf(gpu->command, sizeof(gpu->command), "");
    return;
  }
  if (sample.utilization > 100) sample.utilization = 100;
  sample.temperature = temps_average(temps, &temps->gpu);

  char temperature_label[16];
  temps_label(sample.temperature, temperature_label,
              sizeof(temperature_label));
  double gib = 1024. * 1024. * 1024.;
  char memory_label[32];
  if (gpu->memory_limit > 0) {
    snprintf(memory_label, sizeof(memory_label), "%.1f / %.0f GB",
             sample.memory_in_use / gib, gpu->memory_limit / gib);
  } else {
    snprintf(memory_label, sizeof(memory_label), "%.1f GB",
             sample.memory_in_use / gib);
  }

  const char* utilization_color = usage_color(sample.utilization,
                                              USAGE_YELLOW_PERCENT,
                                              USAGE_RED_PERCENT);
  const char* temperature_color = usage_color((int)(sample.temperature + 0.5),
                                              USAGE_YELLOW_CELSIUS,
                                              USAGE_RED_CELSIUS);

  int written = snprintf(
    gpu->command, sizeof(gpu->command),
    "--push gpu.graph %.2f "
    "--set gpu.top label='G %s' label.color=%s "
    "--set gpu.percent label='%d%%' label.color=%s "
    "--set gpu.popup.util label='%d%%' label.color=%s "
    "--set gpu.popup.stages label='%d%% / %d%%' "
    "--set gpu.popup.memory label='%s' "
    "--set gpu.popup.temp label='%sC' label.color=%s",
    sample.utilization / 100.,
    temperature_label, temperature_color,
    sample.utilization, utilization_color,
    sample.utilization, utilization_color,
    sample.renderer, sample.tiler,
    memory_label,
    temperature_label, temperature_color);

  size_t length = written > 0 ? (size_t)written : 0;
  if (length < sizeof(gpu->command)) {
    gpu_append_top_procs(gpu, procs, proc_count, now, &length);
  }

  memcpy(gpu->procs, procs, proc_count * sizeof(struct gpu_proc));
  gpu->proc_count = proc_count;
  gpu->procs_timestamp = now;
  gpu->has_prev_procs = true;
}
