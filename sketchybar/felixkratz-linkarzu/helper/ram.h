#include <mach/mach.h>
#include <mach/vm_statistics.h>
#include <stdio.h>
#include <string.h>
#include <sys/sysctl.h>
#include "apps.h"

// Must match RAM_POPUP_APPS in items/ram.sh.
#define RAM_TOP_APPS 8

struct ram {
  host_t host;
  uint64_t memory_size;
  vm_size_t page_size;
  char command[4096];
};

static inline void ram_init(struct ram* ram) {
  ram->host = mach_host_self();
  ram->memory_size = 0;
  ram->page_size = 0;
  snprintf(ram->command, sizeof(ram->command), "");

  size_t memory_size_length = sizeof(ram->memory_size);
  if (sysctlbyname("hw.memsize", &ram->memory_size, &memory_size_length, NULL, 0) != 0) {
    printf("Error: Could not read physical memory size.\n");
  }

  if (host_page_size(ram->host, &ram->page_size) != KERN_SUCCESS) {
    printf("Error: Could not read memory page size.\n");
  }
}

// Appends the top apps by memory footprint (Activity Monitor's Memory
// column). There is no "other" row: footprints count compressed memory at its
// uncompressed size, so they don't subtract cleanly from used memory.
static inline void ram_append_top_apps(struct ram* ram,
                                       struct apps* apps,
                                       size_t* length) {
  qsort(apps->usage, apps->usage_count, sizeof(struct app_usage),
        apps_compare_footprint);

  double gib = 1024. * 1024. * 1024.;
  for (uint32_t i = 0; i < RAM_TOP_APPS; i++) {
    size_t remaining = sizeof(ram->command) - *length;
    int written;
    if (i < apps->usage_count) {
      struct app_usage* app = &apps->usage[i];
      char name[APP_NAME_LEN + sizeof(APP_NAME_ELLIPSIS) + 16];
      char size[32];
      apps_row_name(app, name, sizeof(name));
      apps_format_bytes(app->footprint, size, sizeof(size));
      written = snprintf(ram->command + *length, remaining,
                         " --set ram.popup.app.%u drawing=on "
                         "icon='%s' label='%s' label.color=%s",
                         i + 1,
                         name,
                         size,
                         apps_color(app->footprint / gib, 2, 4, 8));
    } else {
      written = snprintf(ram->command + *length, remaining,
                         " --set ram.popup.app.%u drawing=off", i + 1);
    }
    if (written < 0 || (size_t)written >= remaining) return;
    *length += written;
  }
}

static inline void ram_update(struct ram* ram, struct apps* apps) {
  vm_statistics64_data_t vm_stats;
  mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
  if (host_statistics64(ram->host,
                        HOST_VM_INFO64,
                        (host_info64_t)&vm_stats,
                        &count) != KERN_SUCCESS) {
    printf("Error: Could not read virtual memory statistics.\n");
    return;
  }

  struct xsw_usage swap_usage;
  size_t swap_usage_length = sizeof(swap_usage);
  if (sysctlbyname("vm.swapusage", &swap_usage, &swap_usage_length, NULL, 0) != 0) {
    printf("Error: Could not read swap usage.\n");
    return;
  }

  // 1 is normal, 2 is warning and 4 is critical.
  int pressure = 0;
  size_t pressure_length = sizeof(pressure);
  sysctlbyname("kern.memorystatus_vm_pressure_level",
               &pressure, &pressure_length, NULL, 0);

  // Active, wired, and compressed pages exclude reclaimable file cache.
  uint64_t used_pages = (uint64_t)vm_stats.active_count
                        + vm_stats.wire_count
                        + vm_stats.compressor_page_count;
  uint64_t used_bytes = used_pages * ram->page_size;
  double ram_percent = (double)used_bytes / (double)ram->memory_size;
  double swap_percent = (double)swap_usage.xsu_used / (double)ram->memory_size;
  double gib = 1024. * 1024. * 1024.;
  double swap_gib = (double)swap_usage.xsu_used / gib;

  if (ram_percent > 1.) ram_percent = 1.;
  if (swap_percent > 1.) swap_percent = 1.;

  // Swap only matters when macOS is short on memory, so color it by pressure.
  const char* pressure_label = "Normal";
  const char* pressure_color = usage_color(0, 1, 2);
  if (pressure >= 4) {
    pressure_label = "Critical";
    pressure_color = usage_color(3, 1, 2);
  } else if (pressure >= 2) {
    pressure_label = "Warning";
    pressure_color = usage_color(2, 1, 2);
  }

  // Color by the shown value so the label and its color always agree.
  int percent = (int)(ram_percent * 100. + 0.5);
  const char* color = usage_color(percent,
                                  USAGE_YELLOW_PERCENT,
                                  USAGE_RED_PERCENT);

  int written = snprintf(
    ram->command, sizeof(ram->command),
    "--push ram.swap %.2f "
    "--push ram.graph %.2f "
    "--set ram.top label='R %.0fG' label.color=%s "
    "--set ram.percent label='%d%%' label.color=%s "
    "--set ram.popup.used label='%.1f / %.0f GB' label.color=%s "
    "--set ram.popup.wired label='%.1f GB' "
    "--set ram.popup.compressed label='%.1f GB' "
    "--set ram.popup.cached label='%.1f GB' "
    "--set ram.popup.swap label='%.1f GB' "
    "--set ram.popup.pressure label='%s' label.color=%s",
    swap_percent,
    ram_percent,
    swap_gib, pressure_color,
    percent, color,
    used_bytes / gib, ram->memory_size / gib,
    color,
    (double)vm_stats.wire_count * ram->page_size / gib,
    (double)vm_stats.compressor_page_count * ram->page_size / gib,
    (double)vm_stats.external_page_count * ram->page_size / gib,
    swap_gib,
    pressure_label, pressure_color);

  size_t length = written > 0 ? (size_t)written : 0;
  if (length < sizeof(ram->command) && apps_sample(apps, false)) {
    ram_append_top_apps(ram, apps, &length);
  }
}
