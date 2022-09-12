#ifndef UMAMUSUMELOCALIFY_LOG
#define UMAMUSUMELOCALIFY_LOG

#include <os/log.h>

#include <string.h>

#define LOG_TAG "UmamusumeLocalify"

#define LOGD(_message, ...)                                                    \
  os_log_debug(OS_LOG_DEFAULT, "<Localify> " _message __VA_OPT__(,) __VA_ARGS__)
#define LOGE(_message, ...)                                                    \
  os_log_error(OS_LOG_DEFAULT, "<Localify> " _message __VA_OPT__(,) __VA_ARGS__)
#define LOGF(_message, ...)                                                    \
  os_log_fault(OS_LOG_DEFAULT, "<Localify> " _message __VA_OPT__(,) __VA_ARGS__)
#define LOGI(_message, ...)                                                    \
  os_log_info(OS_LOG_DEFAULT, "<Localify> " _message __VA_OPT__(,) __VA_ARGS__)
#define LOGW(_message, ...)                                                    \
  os_log(OS_LOG_DEFAULT, "<Localify> " _message __VA_OPT__(,) __VA_ARGS__)

#endif // UMAMUSUMELOCALIFY_LOG
