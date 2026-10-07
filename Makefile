ARCHS = arm64e

TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NSURLHook

NSURLHook_FILES = Tweak.xm
NSURLHook_CFLAGS = -fobjc-arc
NSURLHook_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
