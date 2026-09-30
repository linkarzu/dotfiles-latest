#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>
#include <stdbool.h>
#include <time.h>
#include "apps.h"
#include "temps.h"

#define MAX_TOPPROC_LEN 28
#define TOPPROC_ELLIPSIS_LEN 3

// Must match CPU_POPUP_APPS in items/cpu.sh.
#define CPU_TOP_APPS 8

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;
  uint32_t topproc_max_len;

  char command[4096];
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

  snprintf(cpu->command, sizeof(cpu->command), "");
}

// Shortens the top app name so it fits inside the graph.
static inline void cpu_topproc_label(struct cpu* cpu,
                                     const char* name,
                                     char* out) {
  uint32_t caret = 0;
  for (uint32_t i = 0; name[i] != '\0' && caret < cpu->topproc_max_len; i++) {
    out[caret++] = name[i];
  }
  out[caret] = '\0';
  if (strlen(name) > cpu->topproc_max_len) strcat(out, "...");
}

// Appends the top apps by CPU share of the whole machine, plus whatever the
// readable apps don't account for: root processes like WindowServer and
// processes that started and exited between two updates.
static inline void cpu_append_top_apps(struct cpu* cpu,
                                       struct apps* apps,
                                       double total_percent,
                                       size_t* length) {
  qsort(apps->usage, apps->usage_count, sizeof(struct app_usage),
        apps_compare_cpu);

  double apps_percent = 0;
  for (uint32_t i = 0; i < apps->usage_count; i++) {
    apps_percent += apps->usage[i].cpu_percent;
  }

  for (uint32_t i = 0; i < CPU_TOP_APPS; i++) {
    size_t remaining = sizeof(cpu->command) - *length;
    int written;
    struct app_usage* app = i < apps->usage_count ? &apps->usage[i] : NULL;
    if (app && app->cpu_percent >= 0.1) {
      char name[APP_NAME_LEN + sizeof(APP_NAME_ELLIPSIS) + 16];
      apps_row_name(app, name, sizeof(name));
      written = snprintf(cpu->command + *length, remaining,
                         " --set cpu.popup.app.%u drawing=on "
                         "icon='%s' label='%.1f%%' label.color=%s",
                         i + 1,
                         name,
                         app->cpu_percent,
                         apps_color(app->cpu_percent, 10, 25, 50));
    } else {
      written = snprintf(cpu->command + *length, remaining,
                         " --set cpu.popup.app.%u drawing=off", i + 1);
    }
    if (written < 0 || (size_t)written >= remaining) return;
    *length += written;
  }

  double other_percent = total_percent - apps_percent;
  if (other_percent < 0) other_percent = 0;
  size_t remaining = sizeof(cpu->command) - *length;
  int written = snprintf(cpu->command + *length, remaining,
                         " --set cpu.popup.other label='%.1f%%' label.color=%s",
                         other_percent,
                         apps_color(other_percent, 10, 25, 50));
  if (written > 0 && (size_t)written < remaining) *length += written;
}

static inline void cpu_update(struct cpu* cpu,
                              struct apps* apps,
                              struct temps* temps) {
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read cpu host statistics.\n");
    return;
  }

  // Sample apps on every update so their CPU time covers the same interval.
  bool has_apps = apps_sample(apps, true);

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

    // The label above the graph names the app using the most CPU.
    char topproc[MAX_TOPPROC_LEN + TOPPROC_ELLIPSIS_LEN + 1] = "";
    struct app_usage* top_app = NULL;
    for (uint32_t i = 0; i < apps->usage_count; i++) {
      if (!top_app || apps->usage[i].cpu_percent > top_app->cpu_percent) {
        top_app = &apps->usage[i];
      }
    }
    if (has_apps && top_app) cpu_topproc_label(cpu, top_app->name, topproc);

    // Color by the shown value so the label and its color always agree.
    int percent = (int)(total_perc * 100. + 0.5);
    const char* color = usage_color(percent,
                                    USAGE_YELLOW_PERCENT,
                                    USAGE_RED_PERCENT);

    double celsius = temps_average(temps, &temps->cpu);
    char temperature[16];
    temps_label(celsius, temperature, sizeof(temperature));
    const char* temperature_color = usage_color((int)(celsius + 0.5),
                                                USAGE_YELLOW_CELSIUS,
                                                USAGE_RED_CELSIUS);

    double load[3] = { 0, 0, 0 };
    getloadavg(load, 3);

    int written = snprintf(cpu->command, sizeof(cpu->command),
                           "--push cpu.sys %.2f "
                           "--push cpu.graph %.2f "
                           "--set cpu.process label='%s' "
                           "--set cpu.top label='C %s' label.color=%s "
                           "--set cpu.percent label='%d%%' label.color=%s "
                           "--set cpu.popup.usage label='%d%%' label.color=%s "
                           "--set cpu.popup.split label='%.0f%% / %.0f%%' "
                           "--set cpu.popup.load label='%.1f %.1f %.1f' "
                           "--set cpu.popup.temp label='%sC' label.color=%s",
                           sys_perc,
                           total_perc,
                           topproc,
                           temperature,
                           temperature_color,
                           percent,
                           color,
                           percent,
                           color,
                           user_perc*100.,
                           sys_perc*100.,
                           load[0], load[1], load[2],
                           temperature,
                           temperature_color);

    size_t length = written > 0 ? (size_t)written : 0;
    if (has_apps && length < sizeof(cpu->command)) {
      cpu_append_top_apps(cpu, apps, total_perc * 100., &length);
    }
  }
  else {
    snprintf(cpu->command, sizeof(cpu->command), "");
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;
}
