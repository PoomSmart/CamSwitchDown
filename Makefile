PACKAGE_VERSION = 1.5.0
TARGET = iphone:clang:latest:7.0
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CamSwitchDown
$(TWEAK_NAME)_FILES = TweakCommon.x Tweak9.x Tweak8.x Tweak7.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
