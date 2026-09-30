#pragma once

#include <libproc.h>
#include <mach/mach_time.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <unistd.h>

// Private libsystem API: the app macOS holds responsible for a process, so
// helpers, renderers and XPC services are counted under the app that owns them.
int responsibility_get_pid_responsible_for_pid(pid_t pid);

#define APPS_MAX_PROCS 4096
#define APPS_MAX 1024
#define APP_NAME_LEN 20
#define APP_NAME_ELLIPSIS "..."

struct app_proc {
  pid_t pid;
  uint64_t start;
  uint64_t cpu_time;
};

struct app_usage {
  char name[APP_NAME_LEN + sizeof(APP_NAME_ELLIPSIS)];
  uint32_t proc_count;
  uint64_t cpu_ns;
  uint64_t footprint;
  double cpu_percent;
};

struct apps {
  mach_timebase_info_data_t timebase;
  long cpu_count;

  // Per-process CPU time from the previous CPU sample, sorted by pid.
  struct app_proc procs[APPS_MAX_PROCS];
  uint32_t proc_count;
  uint64_t timestamp;
  bool has_prev;

  // Only processes of the current user are readable, root ones are skipped.
  struct app_usage usage[APPS_MAX];
  uint32_t usage_count;
};

static inline void apps_init(struct apps* apps) {
  mach_timebase_info(&apps->timebase);
  apps->cpu_count = sysconf(_SC_NPROCESSORS_ONLN);
  if (apps->cpu_count < 1) apps->cpu_count = 1;
  apps->proc_count = 0;
  apps->timestamp = 0;
  apps->has_prev = false;
  apps->usage_count = 0;
}

static inline uint64_t apps_to_ns(struct apps* apps, uint64_t mach_time) {
  return mach_time * apps->timebase.numer / apps->timebase.denom;
}

// Names a process after the outermost .app bundle it runs from, falling back
// to the executable name for command line tools.
static inline void apps_name_for_pid(pid_t pid, char* out) {
  char path[PROC_PIDPATHINFO_MAXSIZE];
  const char* name = "Unknown";
  if (proc_pidpath(pid, path, sizeof(path)) > 0) {
    char* bundle = strstr(path, ".app/");
    if (bundle) *bundle = '\0';
    char* slash = strrchr(path, '/');
    name = slash ? slash + 1 : path;
  }

  // Drop quotes so the name can't break the sketchybar command.
  uint32_t caret = 0;
  for (uint32_t i = 0; name[i] != '\0' && caret < APP_NAME_LEN; i++) {
    if (name[i] == '\'' || name[i] == '"') continue;
    out[caret++] = name[i];
  }
  out[caret] = '\0';
  if (strlen(name) > APP_NAME_LEN) strcat(out, APP_NAME_ELLIPSIS);
}

static inline struct app_usage* apps_find_or_add(struct apps* apps,
                                                 const char* name) {
  for (uint32_t i = 0; i < apps->usage_count; i++) {
    if (strcmp(apps->usage[i].name, name) == 0) return &apps->usage[i];
  }
  if (apps->usage_count >= APPS_MAX) return NULL;

  struct app_usage* app = &apps->usage[apps->usage_count++];
  snprintf(app->name, sizeof(app->name), "%s", name);
  app->proc_count = 0;
  app->cpu_ns = 0;
  app->footprint = 0;
  app->cpu_percent = 0;
  return app;
}

static inline int apps_compare_pid(const void* a, const void* b) {
  pid_t left = ((const struct app_proc*)a)->pid;
  pid_t right = ((const struct app_proc*)b)->pid;
  return (left > right) - (left < right);
}

static inline int apps_compare_cpu(const void* a, const void* b) {
  double left = ((const struct app_usage*)a)->cpu_percent;
  double right = ((const struct app_usage*)b)->cpu_percent;
  return (left < right) - (left > right);
}

static inline int apps_compare_footprint(const void* a, const void* b) {
  uint64_t left = ((const struct app_usage*)a)->footprint;
  uint64_t right = ((const struct app_usage*)b)->footprint;
  return (left < right) - (left > right);
}

// Groups every readable process under its responsible app. With track_cpu,
// each app's CPU share of the whole machine since the previous CPU sample is
// computed too; it returns false while there is no previous sample yet.
static inline bool apps_sample(struct apps* apps, bool track_cpu) {
  static pid_t pids[APPS_MAX_PROCS];
  static struct app_proc current[APPS_MAX_PROCS];
  int pid_count = proc_listallpids(pids, sizeof(pids));
  if (pid_count <= 0) return false;

  uint64_t now = mach_absolute_time();
  uint64_t elapsed_ns = apps_to_ns(apps, now - apps->timestamp);
  bool has_delta = track_cpu && apps->has_prev && elapsed_ns > 0;
  uint32_t current_count = 0;
  apps->usage_count = 0;

  for (int i = 0; i < pid_count; i++) {
    struct rusage_info_v4 info;
    if (proc_pid_rusage(pids[i], RUSAGE_INFO_V4, (rusage_info_t*)&info) != 0) {
      continue;
    }

    pid_t owner = responsibility_get_pid_responsible_for_pid(pids[i]);
    if (owner <= 0) owner = pids[i];
    char name[APP_NAME_LEN + sizeof(APP_NAME_ELLIPSIS)];
    apps_name_for_pid(owner, name);

    struct app_usage* app = apps_find_or_add(apps, name);
    if (!app) continue;
    app->proc_count++;
    app->footprint += info.ri_phys_footprint;

    if (!track_cpu || current_count >= APPS_MAX_PROCS) continue;
    struct app_proc* proc = &current[current_count++];
    proc->pid = pids[i];
    proc->start = info.ri_proc_start_abstime;
    proc->cpu_time = info.ri_user_time + info.ri_system_time;

    if (!has_delta) continue;
    struct app_proc* prev = bsearch(proc, apps->procs, apps->proc_count,
                                    sizeof(struct app_proc), apps_compare_pid);
    // A reused pid is a new process, count all of its time since it started.
    uint64_t prev_time = prev && prev->start == proc->start ? prev->cpu_time
                                                            : 0;
    if (proc->cpu_time > prev_time) {
      app->cpu_ns += apps_to_ns(apps, proc->cpu_time - prev_time);
    }
  }

  if (!track_cpu) return true;

  for (uint32_t i = 0; i < apps->usage_count; i++) {
    apps->usage[i].cpu_percent = has_delta
      ? (double)apps->usage[i].cpu_ns
        / ((double)elapsed_ns * (double)apps->cpu_count) * 100.
      : 0;
  }

  qsort(current, current_count, sizeof(struct app_proc), apps_compare_pid);
  memcpy(apps->procs, current, current_count * sizeof(struct app_proc));
  apps->proc_count = current_count;
  apps->timestamp = now;
  apps->has_prev = true;
  return has_delta;
}

static inline const char* apps_color(double value,
                                     double yellow,
                                     double orange,
                                     double red) {
  const char* color;
  if (value >= red) color = getenv("RED");
  else if (value >= orange) color = getenv("ORANGE");
  else if (value >= yellow) color = getenv("YELLOW");
  else color = getenv("LABEL_COLOR");
  return color ? color : "0xffffffff";
}

// Shared by the CPU, RAM and GPU bar labels so they all color the same way.
#define USAGE_YELLOW_PERCENT 50
#define USAGE_RED_PERCENT 85
#define USAGE_YELLOW_CELSIUS 70
#define USAGE_RED_CELSIUS 90

// White when normal, yellow above the first threshold, red above the second.
static inline const char* usage_color(double value,
                                      double yellow,
                                      double red) {
  const char* color;
  if (value > red) color = getenv("RED");
  else if (value > yellow) color = getenv("YELLOW");
  else color = getenv("WHITE");
  return color ? color : "0xffffffff";
}

// Popup row name, with the process count when an app has more than one.
static inline void apps_row_name(struct app_usage* app,
                                 char* out,
                                 size_t size) {
  if (app->proc_count > 1) {
    snprintf(out, size, "%s (%u)", app->name, app->proc_count);
  } else {
    snprintf(out, size, "%s", app->name);
  }
}

// Formats bytes as GB, or MB below one gigabyte.
static inline void apps_format_bytes(uint64_t bytes, char* out, size_t size) {
  double gib = 1024. * 1024. * 1024.;
  if (bytes >= gib) snprintf(out, size, "%.2f GB", bytes / gib);
  else snprintf(out, size, "%.0f MB", bytes / (1024. * 1024.));
}
