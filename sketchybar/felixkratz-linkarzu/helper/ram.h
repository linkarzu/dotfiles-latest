#include <mach/mach.h>
#include <mach/vm_statistics.h>
#include <stdio.h>
#include <string.h>
#include <sys/sysctl.h>

struct ram {
  host_t host;
  uint64_t memory_size;
  vm_size_t page_size;
  char command[256];
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

static inline void ram_update(struct ram* ram) {
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

  // Active, wired, and compressed pages exclude reclaimable file cache.
  uint64_t used_pages = (uint64_t)vm_stats.active_count
                        + vm_stats.wire_count
                        + vm_stats.compressor_page_count;
  double ram_percent = (double)(used_pages * ram->page_size)
                       / (double)ram->memory_size;
  double swap_percent = (double)swap_usage.xsu_used / (double)ram->memory_size;
  double swap_gib = (double)swap_usage.xsu_used / (1024. * 1024. * 1024.);

  if (ram_percent > 1.) ram_percent = 1.;
  if (swap_percent > 1.) swap_percent = 1.;

  snprintf(ram->command, sizeof(ram->command),
           "--push ram.used %.2f "
           "--push swap.used %.2f "
           "--set ram.top label='ram %.0f%%' "
           "--set swap.percent label='swp %.0fG'",
           ram_percent,
           swap_percent,
           ram_percent * 100.,
           swap_gib);
}
