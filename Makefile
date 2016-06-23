DEBUG = 0
GO_EASY_ON_ME = 1
PACKAGE_VERSION = 1.3
TARGET = iphone:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CamSwitchDown
CamSwitchDown_FILES = Tweak.xm
CamSwitchDown_PRIVATE_FRAMEWORKS = CameraUI

include $(THEOS_MAKE_PATH)/tweak.mk


