TARGET = iphone:clang:latest:12.2
INSTALL_TARGET_PROCESSES = Microphone

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Microphone

Microphone_FILES = AppDelegate.swift RootViewController.swift
Microphone_FRAMEWORKS = UIKit CoreGraphics AVFoundation AVFAudio AudioToolbox
#Microphone_CODESIGN_FLAGS = -SMicrophoneEntitlements.xml

include $(THEOS_MAKE_PATH)/application.mk
