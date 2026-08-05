#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>
#include <stdbool.h>
#include <time.h>

#define MAX_TOPPROC_LEN 28
#define TOPPROC_ELLIPSIS_LEN 3

static const char TOPPROC[] = { "/bin/ps -Aceo pid,pcpu,comm -r" }; 
static const char FILTER_PATTERN[] = { "com.apple." };

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;
  uint32_t topproc_max_len;

  char command[256];
};

static inline void cpu_init(struct cpu* cpu) {
  cpu->host = mach_host_self();
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  cpu->has_prev_load = false;
  cpu->topproc_max_len = MAX_TOPPROC_LEN;

  char* max_chars = getenv("CPU_TOPPROC_MAX_CHARS");
  if (max_chars) {
    char* end;
    long value = strtol(max_chars, &end, 10);
    if (*max_chars != '\0' && *end == '\0'
        && value > 0 && value <= MAX_TOPPROC_LEN) {
      cpu->topproc_max_len = (uint32_t)value;
    }
  }

  snprintf(cpu->command, 100, "");
}

static inline void cpu_update(struct cpu* cpu) {
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read cpu host statistics.\n");
    return;
  }

  if (cpu->has_prev_load) {
    uint32_t delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];

    uint32_t delta_system = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                            - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];

    uint32_t delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];

    double user_perc = (double)delta_user / (double)(delta_system
                                                     + delta_user
                                                     + delta_idle);

    double sys_perc = (double)delta_system / (double)(delta_system
                                                      + delta_user
                                                      + delta_idle);

    double total_perc = user_perc + sys_perc;

    FILE* file;
    char line[1024];

    file = popen(TOPPROC, "r");
    if (!file) {
      printf("Error: TOPPROC command errored out...\n" );
      return;
    }

    fgets(line, sizeof(line), file);
    fgets(line, sizeof(line), file);

    char* start = strstr(line, FILTER_PATTERN);
    char topproc[MAX_TOPPROC_LEN + TOPPROC_ELLIPSIS_LEN + 1];
    uint32_t caret = 0;
    for (int i = 0; i < sizeof(line); i++) {
      if (start && i == start - line) {
        i+=9;
        continue;
      }

      if (caret >= cpu->topproc_max_len
          && caret < cpu->topproc_max_len + TOPPROC_ELLIPSIS_LEN) {
        topproc[caret++] = '.';
        continue;
      }
      if (caret >= cpu->topproc_max_len + TOPPROC_ELLIPSIS_LEN) break;
      topproc[caret++] = line[i];
      if (line[i] == '\0') break;
    }

    topproc[cpu->topproc_max_len + TOPPROC_ELLIPSIS_LEN] = '\0';

    pclose(file);

    char color[16];
    if (total_perc >= .7) {
      snprintf(color, 16, "%s", getenv("RED"));
    } else if (total_perc >= .3) {
      snprintf(color, 16, "%s", getenv("ORANGE"));
    } else if (total_perc >= .1) {
      snprintf(color, 16, "%s", getenv("YELLOW"));
    } else {
      snprintf(color, 16, "%s", getenv("LABEL_COLOR"));
    }

    snprintf(cpu->command, 256, "--push cpu.sys %.2f "
                                "--push cpu.user %.2f "
                                "--set cpu.top label='%s' "
                                "--set cpu.percent label=%.0f%% label.color=%s ",
                                sys_perc,
                                user_perc,
                                topproc,
                                total_perc*100.,
                                color          );
  }
  else {
    snprintf(cpu->command, 256, "");
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;
}
