#pragma once

#include <IOKit/IOKitLib.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

// Reads the Apple Silicon CPU and GPU temperatures from the SMC. The SMC has
// separate sensors per P-core cluster (Tp..), E-core cluster (Te..) and GPU
// (Tg..), unlike the HID die sensors, which can't be told apart.

#define SMC_CMD_READ_BYTES 5
#define SMC_CMD_READ_INDEX 8
#define SMC_CMD_READ_KEYINFO 9
#define SMC_KERNEL_INDEX 2
#define TEMPS_MAX_SENSORS 256

struct smc_key_info {
  uint32_t size;
  uint32_t type;
  uint8_t attributes;
};

// Layout expected by the AppleSMC user client.
struct smc_param {
  uint32_t key;
  uint8_t vers[6];
  uint8_t plimit[16];
  struct smc_key_info info;
  uint8_t result;
  uint8_t status;
  uint8_t command;
  uint32_t index;
  uint8_t bytes[32];
};

struct temps_group {
  uint32_t keys[TEMPS_MAX_SENSORS];
  struct smc_key_info infos[TEMPS_MAX_SENSORS];
  uint32_t count;
};

struct temps {
  bool initialized;
  io_connect_t connection;
  struct temps_group cpu;
  struct temps_group gpu;
};

static inline uint32_t temps_key(const char* name) {
  return (uint32_t)name[0] << 24 | (uint32_t)name[1] << 16
         | (uint32_t)name[2] << 8 | (uint32_t)name[3];
}

static inline bool temps_call(struct temps* temps,
                              struct smc_param* in,
                              struct smc_param* out) {
  size_t size = sizeof(*out);
  memset(out, 0, sizeof(*out));
  return IOConnectCallStructMethod(temps->connection, SMC_KERNEL_INDEX,
                                   in, sizeof(*in), out, &size)
         == KERN_SUCCESS && out->result == 0;
}

static inline bool temps_read_info(struct temps* temps,
                                   uint32_t key,
                                   struct smc_key_info* info) {
  struct smc_param in = { 0 }, out;
  in.key = key;
  in.command = SMC_CMD_READ_KEYINFO;
  if (!temps_call(temps, &in, &out)) return false;
  *info = out.info;
  return true;
}

static inline void temps_add(struct temps_group* group,
                             uint32_t key,
                             struct smc_key_info* info) {
  if (group->count >= TEMPS_MAX_SENSORS) return;
  group->keys[group->count] = key;
  group->infos[group->count] = *info;
  group->count++;
}

// Finds the sensors once, reading them every update is cheap. Called on the
// first read, scanning every SMC key at startup delays the helper's mach
// registration, and sketchybar drops items whose mach_helper isn't up yet.
static inline void temps_init(struct temps* temps) {
  temps->initialized = true;
  temps->connection = 0;
  temps->cpu.count = 0;
  temps->gpu.count = 0;

  io_service_t service = IOServiceGetMatchingService(
    kIOMainPortDefault, IOServiceMatching("AppleSMC"));
  if (!service) {
    printf("Error: Could not find the SMC.\n");
    return;
  }
  kern_return_t error = IOServiceOpen(service, mach_task_self(), 0,
                                      &temps->connection);
  IOObjectRelease(service);
  if (error != KERN_SUCCESS) {
    printf("Error: Could not open the SMC.\n");
    temps->connection = 0;
    return;
  }

  struct smc_key_info info;
  struct smc_param in = { 0 }, out;
  in.key = temps_key("#KEY");
  if (!temps_read_info(temps, in.key, &info)) return;
  in.info = info;
  in.command = SMC_CMD_READ_BYTES;
  if (!temps_call(temps, &in, &out)) return;
  uint32_t key_count = (uint32_t)out.bytes[0] << 24
                       | (uint32_t)out.bytes[1] << 16
                       | (uint32_t)out.bytes[2] << 8
                       | (uint32_t)out.bytes[3];

  for (uint32_t i = 0; i < key_count; i++) {
    struct smc_param index_in = { 0 };
    index_in.command = SMC_CMD_READ_INDEX;
    index_in.index = i;
    if (!temps_call(temps, &index_in, &out)) continue;

    uint32_t key = out.key;
    char type = (char)(key >> 16);
    char third = (char)(key >> 8);
    if ((char)(key >> 24) != 'T') continue;
    // Tpx../Tex.. are cluster summaries that hold peak values, skip them.
    if (third == 'x') continue;
    if (type != 'p' && type != 'e' && type != 'g') continue;

    if (!temps_read_info(temps, key, &info)) continue;
    if (info.type != temps_key("flt ") || info.size != 4) continue;
    temps_add(type == 'g' ? &temps->gpu : &temps->cpu, key, &info);
  }

  if (temps->cpu.count == 0) printf("Error: No CPU temperature sensors.\n");
  if (temps->gpu.count == 0) printf("Error: No GPU temperature sensors.\n");
}

// Returns the average of the group's sensors in Celsius, or -1 on error.
static inline double temps_average(struct temps* temps,
                                   struct temps_group* group) {
  if (!temps->initialized) temps_init(temps);
  if (!temps->connection) return -1;

  double sum = 0;
  uint32_t count = 0;
  for (uint32_t i = 0; i < group->count; i++) {
    struct smc_param in = { 0 }, out;
    in.key = group->keys[i];
    in.info = group->infos[i];
    in.command = SMC_CMD_READ_BYTES;
    if (!temps_call(temps, &in, &out)) continue;

    float celsius;
    memcpy(&celsius, out.bytes, sizeof(celsius));
    // Idle or uncalibrated sensors report zero or nonsense values.
    if (celsius > 0 && celsius < 150) {
      sum += celsius;
      count++;
    }
  }
  return count > 0 ? sum / count : -1;
}

// Temperature label like "46°", or "--°" when it can't be read.
static inline void temps_label(double celsius, char* out, size_t size) {
  if (celsius >= 0) snprintf(out, size, "%.0f°", celsius);
  else snprintf(out, size, "--°");
}
