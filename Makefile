DEBUG = 0
SDKVERSION = 9.0
GO_EASY_ON_ME = 1
PACKAGE_VERSION = 1.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CamSwitchDown
CamSwitchDown_FILES = Tweak.xm
CamSwitchDown_PRIVATE_FRAMEWORKS = CameraUI

include $(THEOS_MAKE_PATH)/tweak.mk


