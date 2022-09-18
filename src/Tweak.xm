#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSUserDefaults+Private.h>

#import <dlfcn.h>

#import <pthread.h>

#import <vector>

#import "hook.h"

#import "utils.h"

#import "thread_args.hpp"

const char *bundle_version;

const char *document_path;

int max_fps = 30;
float ui_animation_scale = 1.0f;
bool ui_use_system_resolution = false;
bool replace_to_builtin_font = false;
bool replace_to_custom_font = false;
const char *replace_assets_path;
const char *font_assetbundle_path;
const char *font_asset_name;
int graphics_quality = -1;
int anti_aliasing = -1;
bool force_landscape = false;
float force_landscape_ui_scale = 0.5;
bool ui_loading_show_orientation_guide = true;

int UIInterfaceOrientationUnknown = 1, UIInterfaceOrientationPortrait = 2,
    UIInterfaceOrientationPortraitUpsideDown = 3,
    UIInterfaceOrientationLandscapeLeft = 4,
    UIInterfaceOrientationLandscapeRight = 5;

int UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft =
        (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight =
        (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown =
        (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape =
        (UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll =
        (UIInterfaceOrientationMaskPortrait |
         UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight |
         UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown =
        (UIInterfaceOrientationMaskPortrait |
         UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight);

static bool UISupportsTrueScreenSizeOnMac = false;

%hook Crackify
+ (bool)isJailbroken {
  return NO; 
}

+ (bool)isCracked {
  return NO;
}
%end

%hook UIViewController 
- (NSInteger)__supportedInterfaceOrientations {
  if (UISupportsTrueScreenSizeOnMac) {
    return UIInterfaceOrientationMaskAll;
  }
  return force_landscape ? UIInterfaceOrientationMaskAll : %orig();
}
- (void)setInterfaceOrientation:(NSInteger)orientation {
  if (UISupportsTrueScreenSizeOnMac) {
    %orig(UIInterfaceOrientationLandscapeLeft);
  }
  %orig(force_landscape ? UIInterfaceOrientationLandscapeLeft : orientation);
}
%end

static NSString *nsDomainString = @"com.kimjio.umamusumelocalify";
static NSString *nsNotificationString =
    @"com.kimjio.umamusumelocalify/preferences.changed";

// static bool enabled;

static void notificationCallback(CFNotificationCenterRef center, void *observer,
                                 CFStringRef name, const void *object,
                                 CFDictionaryRef userInfo) {
  /* NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults
  standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
  enabled = (enabledValue)? [enabledValue boolValue] : true; */

  NSNumber *maxFpsValue = (NSNumber *)[[NSUserDefaults standardUserDefaults]
      objectForKey:@"maxFps"
          inDomain:nsDomainString];
  max_fps = (maxFpsValue) ? [maxFpsValue intValue] : -1;

  NSNumber *uiAnimationScaleValue =
      (NSNumber *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"uiAnimationScale"
              inDomain:nsDomainString];
  ui_animation_scale =
      (uiAnimationScaleValue) ? [uiAnimationScaleValue floatValue] : 1;

  NSNumber *uiUseSystemResolutionValue =
      (NSNumber *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"uiUseSystemResolution"
              inDomain:nsDomainString];
  ui_use_system_resolution = (uiUseSystemResolutionValue)
                                   ? [uiUseSystemResolutionValue boolValue]
                                   : false;

  NSString *graphicsQualityValue =
      (NSString *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"graphicsQuality"
              inDomain:nsDomainString];
  graphics_quality =
      (graphicsQualityValue) ? [Utils toInt:graphicsQualityValue] : -1;

  if (graphics_quality < -1) {
    graphics_quality = -1;
  }
  if (graphics_quality > 4) {
    graphics_quality = 3;
  }

  NSString *antiAliasingValue =
      (NSString *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"antiAliasing"
              inDomain:nsDomainString];
  anti_aliasing = (antiAliasingValue) ? [Utils toInt:antiAliasingValue] : -1;
  std::vector<int> options = {0, 2, 4, 8, -1};
  anti_aliasing = find(options.begin(), options.end(), anti_aliasing) -
                        options.begin();

  NSNumber *forceLandscapeValue =
      (NSNumber *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"forceLandscape"
              inDomain:nsDomainString];
  force_landscape = UISupportsTrueScreenSizeOnMac ? true
                      : (forceLandscapeValue) ? [forceLandscapeValue boolValue]
                                              : false;

  NSNumber *forceLandscapeUiScaleValue =
      (NSNumber *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"forceLandscapeUiScale"
              inDomain:nsDomainString];
  force_landscape_ui_scale = (forceLandscapeUiScaleValue)
                                   ? [forceLandscapeUiScaleValue floatValue]
                                   : 0.5;
  if (force_landscape_ui_scale <= 0) {
    force_landscape_ui_scale = 1;
  }

  NSNumber *uiLoadingShowOrientationGuideValue =
      (NSNumber *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"uiLoadingShowOrientationGuide"
              inDomain:nsDomainString];
  ui_loading_show_orientation_guide =
      (uiLoadingShowOrientationGuideValue)
          ? [uiLoadingShowOrientationGuideValue boolValue]
          : true;

  NSNumber *replaceToBuiltinFontValue =
      (NSNumber *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"replaceToBuiltinFontValue"
              inDomain:nsDomainString];
  replace_to_builtin_font =
      (replaceToBuiltinFontValue)
          ? [replaceToBuiltinFontValue boolValue]
          : false;

  NSNumber *replaceToCustomFontValue =
      (NSNumber *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"replaceToCustomFont"
              inDomain:nsDomainString];
  replace_to_custom_font =
      (replaceToCustomFontValue)
          ? [replaceToCustomFontValue boolValue]
          : false;

  NSString *replaceAssetsPathValue =
      (NSString *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"replaceAssetsPath"
              inDomain:nsDomainString];
  replace_assets_path = (replaceAssetsPathValue)
                              ? [Utils getCString:replaceAssetsPathValue]
                              : "";

  NSString *fontAssetBundlePathValue =
      (NSString *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"fontAssetBundlePath"
              inDomain:nsDomainString];
  font_assetbundle_path = (fontAssetBundlePathValue)
                              ? [Utils getCString:fontAssetBundlePathValue]
                              : "";

  NSString *fontAssetNameValue =
      (NSString *)[[NSUserDefaults standardUserDefaults]
          objectForKey:@"fontAssetName"
              inDomain:nsDomainString];
  font_asset_name = (fontAssetNameValue)
                              ? [Utils getCString:fontAssetNameValue]
                              : "";
}

%ctor {
  UISupportsTrueScreenSizeOnMac = [[NSBundle mainBundle]
      objectForInfoDictionaryKey:@"UISupportsTrueScreenSizeOnMac"];

  // Set variables on start up
  notificationCallback(nullptr, nullptr, nullptr, nullptr, nullptr);

  // Register for 'PostNotification' notifications
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                  nullptr, notificationCallback,
                                  (CFStringRef)nsNotificationString, nullptr,
                                  CFNotificationSuspensionBehaviorCoalesce);

  // Add any personal initializations
  NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
  NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  
  bundle_version = [Utils getCString:bundleVersion];

  LOGI("Bundle Identifier: %s", [Utils getCString:bundleId]);
  LOGI("Bundle Version: %s", bundle_version);

  NSString *documentPath = [NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
  document_path = [Utils getCString:documentPath];

  NSString *frameworkPath = [[NSBundle mainBundle] privateFrameworksPath];
  NSString *frameworkName = @"UnityFramework.framework/UnityFramework";
  NSString *frameworkFullPath =
      [Utils getNSStringByAppendingPathComponent:frameworkPath
                                            name:frameworkName];
  const char *frameworkFullPathCString = [Utils getCString:frameworkFullPath];
  void *unityFramework = dlopen(frameworkFullPathCString, RTLD_LAZY);

  auto thread_args = (ThreadArgs *)malloc(sizeof(ThreadArgs));
  thread_args->framework = unityFramework;
  thread_args->config = (Config *)malloc(sizeof(Config));
  thread_args->config->bundle_version = bundle_version;
  thread_args->config->document_path = document_path;
  thread_args->config->max_fps = max_fps;
  thread_args->config->ui_animation_scale = ui_animation_scale;
  thread_args->config->ui_use_system_resolution = ui_use_system_resolution;
  thread_args->config->graphics_quality = graphics_quality;
  thread_args->config->anti_aliasing = anti_aliasing;
  thread_args->config->force_landscape = force_landscape;
  thread_args->config->force_landscape_ui_scale = force_landscape_ui_scale;
  thread_args->config->ui_loading_show_orientation_guide = ui_loading_show_orientation_guide;
  thread_args->config->replace_to_builtin_font = replace_to_builtin_font;
  thread_args->config->replace_to_custom_font = replace_to_custom_font;
  thread_args->config->replace_assets_path = replace_assets_path;
  thread_args->config->font_assetbundle_path = font_assetbundle_path;
  thread_args->config->font_asset_name = font_asset_name;

  int ret;
  pthread_t ntid;
  if ((ret = pthread_create(&ntid, nullptr,
                            reinterpret_cast<void *(*)(void *)>(hack_thread),
                            thread_args))) {
    LOGE("can't create thread: %s\n", strerror(ret));
  }
}
