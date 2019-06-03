LOCAL_PATH := $(call my-dir)

$(shell mkdir -p $(TARGET_OUT)/bin/updateNEW)
$(shell mkdir -p $(TARGET_OUT)/bin/updateOLD)
$(shell cp $(LOCAL_PATH)/updateNEW/BOX_ECP5.bit $(TARGET_OUT)/bin/updateNEW)
$(shell cp $(LOCAL_PATH)/updateOLD/BOX_ECP5.bit $(TARGET_OUT)/bin/updateOLD)
$(shell cp $(LOCAL_PATH)/updateNEW/BOX_CROSSLINK.bit $(TARGET_OUT)/bin/updateNEW)
$(shell cp $(LOCAL_PATH)/updateOLD/BOX_CROSSLINK.bit $(TARGET_OUT)/bin/updateOLD)
$(shell cp $(LOCAL_PATH)/updateNEW/BOX_XO3.hex $(TARGET_OUT)/bin/updateNEW)
$(shell cp $(LOCAL_PATH)/updateOLD/BOX_XO3.hex $(TARGET_OUT)/bin/updateOLD)
$(shell cp $(LOCAL_PATH)/updateNEW/CROSSLINKreadback.txt $(TARGET_OUT)/bin/updateNEW)
$(shell cp $(LOCAL_PATH)/updateOLD/CROSSLINKverify.txt $(TARGET_OUT)/bin/updateOLD)
$(shell cp $(LOCAL_PATH)/updateNEW/ECP5readback.txt $(TARGET_OUT)/bin/updateNEW)
$(shell cp $(LOCAL_PATH)/updateOLD/ECP5verify.txt $(TARGET_OUT)/bin/updateOLD)

#######################################

include $(CLEAR_VARS)

LOCAL_MODULE := fpga_box.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_OUT)/bin
LOCAL_SRC_FILES := fpga_box.sh
include $(BUILD_PREBUILT)

#######################################

include $(CLEAR_VARS)

LOCAL_MODULE := fpga_hmd.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_OUT)/bin
LOCAL_SRC_FILES := fpga_hmd.sh
include $(BUILD_PREBUILT)

#######################################

include $(CLEAR_VARS)

LOCAL_MODULE := OTA_fpgaupdate.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_OUT)/bin
LOCAL_SRC_FILES := OTA_fpgaupdate.sh
include $(BUILD_PREBUILT)

#######################################



