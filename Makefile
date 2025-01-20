TARGET = iphone:16.5:12.5
ARCHS = arm64

INSTALL_TARGET_PROCESSES = Microphone

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Microphone

#ExampleApp_XCODEFLAGS = SWIFT_OLD_RPATH=/usr/lib/libswift/stable
ExampleApp_XCODE_SCHEME = Microphone
ExampleApp_CODESIGN_FLAGS = -SMicrophoneEntitlements.xml

include $(THEOS_MAKE_PATH)/xcodeproj.mk