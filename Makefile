TARGET := iphone:clang:latest:14.5
ARCHS = arm64
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = OneStateUltra
OneStateUltra_FILES = Tweak.x
OneStateUltra_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk
