DEBUG = 0
PACKAGE_VERSION = 1.4
TARGET = iphone:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CamSwitchDown
CamSwitchDown_FILES = Tweak.xm
CamSwitchDown_PRIVATE_FRAMEWORKS = CameraUI

include $(THEOS_MAKE_PATH)/tweak.mk