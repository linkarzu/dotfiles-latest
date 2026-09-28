#include "cpu.h"
#include "gpu.h"
#include "ram.h"
#include "sketchybar.h"

struct cpu g_cpu;
struct gpu g_gpu;
struct ram g_ram;

void handler(env env) {
  // Environment variables passed from sketchybar can be accessed as seen below
  char* name = env_get_value_for_key(env, "NAME");
  char* sender = env_get_value_for_key(env, "SENDER");
  char* info = env_get_value_for_key(env, "INFO");
  char* selected = env_get_value_for_key(env, "SELECTED");

  if ((strcmp(name, "cpu.percent") == 0)) {
    // CPU graph updates
    cpu_update(&g_cpu);

    if (strlen(g_cpu.command) > 0) sketchybar(g_cpu.command);
  }
  else if ((strcmp(name, "swap.percent") == 0)) {
    ram_update(&g_ram);

    if (strlen(g_ram.command) > 0) sketchybar(g_ram.command);
  }
  else if ((strcmp(name, "gpu.temp") == 0)) {
    gpu_update(&g_gpu);

    if (strlen(g_gpu.command) > 0) sketchybar(g_gpu.command);
  }
}

int main (int argc, char** argv) {
  cpu_init(&g_cpu);
  gpu_init(&g_gpu);
  ram_init(&g_ram);

  if (argc < 2) {
    printf("Usage: helper \"<bootstrap name>\"\n");
    exit(1);
  }

  event_server_begin(handler, argv[1]);
  return 0;
}
