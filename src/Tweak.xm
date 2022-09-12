#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSUserDefaults+Private.h>

#import <dlfcn.h>

#import <pthread.h>

#import "hook.h"

#import "utils.h"

#import "preferences.h"

int UIInterfaceOrientationUnknown            = 1,
    UIInterfaceOrientationPortrait           = 2,
    UIInterfaceOrientationPortraitUpsideDown = 3,
    UIInterfaceOrientationLandscapeLeft      = 4,
    UIInterfaceOrientationLandscapeRight     = 5;

int UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);

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
	return g_force_landscape ? UIInterfaceOrientationMaskAll : %orig();
}
- (void)setInterfaceOrientation:(NSInteger)orientation {
	if (UISupportsTrueScreenSizeOnMac) {
		%orig(UIInterfaceOrientationLandscapeLeft);
	}
	%orig(g_force_landscape ? UIInterfaceOrientationLandscapeLeft : orientation);
}
%end

static NSString * nsDomainString = @"com.kimjio.umamusumelocalify";
static NSString * nsNotificationString = @"com.kimjio.umamusumelocalify/preferences.changed";

// static bool enabled;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	/* NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue)? [enabledValue boolValue] : true; */
	
	NSNumber * maxFpsValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"maxFps" inDomain:nsDomainString];
	g_max_fps = (maxFpsValue)? [maxFpsValue intValue] : -1;

	NSNumber * uiAnimationScaleValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"uiAnimationScale" inDomain:nsDomainString];
	g_ui_animation_scale = (uiAnimationScaleValue)? [uiAnimationScaleValue floatValue] : 1;

	NSNumber * uiUseSystemResolutionValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"uiUseSystemResolution" inDomain:nsDomainString];
	g_ui_use_system_resolution = (uiUseSystemResolutionValue)? [uiUseSystemResolutionValue boolValue] : false;

	NSString * graphicsQualityValue = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"graphicsQuality" inDomain:nsDomainString];
	g_graphics_quality = (graphicsQualityValue)? [Utils toInt: graphicsQualityValue] : -1;

	NSString * antiAliasingValue = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"antiAliasing" inDomain:nsDomainString];
	g_anti_aliasing = (antiAliasingValue)? [Utils toInt: antiAliasingValue] : -1;

	NSNumber * forceLandscapeValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"forceLandscape" inDomain:nsDomainString];
	g_force_landscape = UISupportsTrueScreenSizeOnMac ? true : (forceLandscapeValue)? [forceLandscapeValue boolValue] : false;

	NSNumber * forceLandscapeUiScaleValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"forceLandscapeUiScale" inDomain:nsDomainString];
	g_force_landscape_ui_scale = (forceLandscapeUiScaleValue)? [forceLandscapeUiScaleValue floatValue] : 0.5;

	NSNumber * uiLoadingShowOrientationGuideValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"uiLoadingShowOrientationGuide" inDomain:nsDomainString];
	g_ui_loading_show_orientation_guide = (uiLoadingShowOrientationGuideValue)? [uiLoadingShowOrientationGuideValue boolValue] : true;
}

%ctor {
	UISupportsTrueScreenSizeOnMac = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportsTrueScreenSizeOnMac"];

	// Set variables on start up
	notificationCallback(nullptr, nullptr, nullptr, nullptr, nullptr);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nullptr, notificationCallback, (CFStringRef)nsNotificationString, nullptr, CFNotificationSuspensionBehaviorCoalesce);

	// Add any personal initializations
	NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
	
	LOGI("Bundle Identifier: %s", [Utils getCString: bundleId]);
    
    int ret;
	pthread_t ntid;
    if ((ret = pthread_create(&ntid, nullptr,
                              reinterpret_cast<void *(*)(void *)>(hack_thread), nullptr))) {
        LOGE("can't create thread: %s\n", strerror(ret));
    }
}
