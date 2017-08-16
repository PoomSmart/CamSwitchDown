PACKAGE_VERSION = 1.4.1
TARGET = iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CamSwitchDown
CamSwitchDown_FILES = TweakCommon.xm Tweak9.xm Tweak8.xm Tweak7.xm

include $(THEOS_MAKE_PATH)/tweak.mk