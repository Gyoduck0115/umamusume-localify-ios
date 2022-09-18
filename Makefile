ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = jp.co.cygames.umamusume com.kakaogames.umamusume com.komoe.kmumamusume

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = UmamusumeLocalify

UmamusumeLocalify_FILES = src/utils.m src/Tweak.xm src/hook.cpp src/il2cpp_hook.cpp src/localify/localify.cpp src/il2cpp/il2cpp_symbols.cpp
UmamusumeLocalify_CFLAGS = -Wno-error=unused-function -Wno-error=unused-variable -Wno-error=return-stack-address -std=c17 -fobjc-arc
UmamusumeLocalify_CCFLAGS = -Wno-error=unused-function  -Wno-error=unused-variable -Wno-error=return-stack-address -std=c++2b -fobjc-arc -Isrc/rapidjson/include

include $(THEOS_MAKE_PATH)/tweak.mk
