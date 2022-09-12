#ifndef UMAMUSUMELOCALIFYANDROID_HOOK_H
#define UMAMUSUMELOCALIFYANDROID_HOOK_H

#include "log.h"

#ifdef __cplusplus
extern "C"
{
#endif

  static bool enable_hack;
  static void *il2cpp_handle = 0;

  void hack_thread(void *args);

#define HOOK_DEF(ret, func, ...)   \
  ret (*orig_##func)(__VA_ARGS__); \
  ret new_##func(__VA_ARGS__)

#ifdef __cplusplus
}
#endif

#endif // UMAMUSUMELOCALIFYANDROID_HOOK_H
