# Copyright (C) 2008 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(TARGET_DEVICE),d2vzw)
ifeq ($(USE_KEXEC),1)

LOCAL_PATH := $(call my-dir)

# output for kexec_boot
KEXEC_BOOT_OUT := $(PRODUCT_OUT)/kexec-boot
KEXEC_BOOT_OUT_UNSTRIPPED := $(TARGET_OUT_UNSTRIPPED)/kexec-boot

# prerequisites for building kexec-boot.zip are defined in KEXEC_BOOT_PREREQS

# we require the kernel, ramdisk, kexec, and kexec.sh
KEXEC_BOOT_PREREQS := $(PRODUCT_OUT)/kernel
KEXEC_BOOT_PREREQS += $(PRODUCT_OUT)/ramdisk.img
KEXEC_BOOT_PREREQS += $(call intermediates-dir-for,UTILITY_EXECUTABLES,kexec)/kexec
KEXEC_BOOT_PREREQS += device/samsung/d2vzw/kexec-boot/kexec.sh

# now we make the kexec-boot target files package
name := $(TARGET_PRODUCT)-kexec_boot_files
intermediates := $(call intermediates-dir-for,PACKAGING,kexec_boot_files)
BUILT_KEXEC_BOOT_FILES_PACKAGE := $(intermediates)/$(name).zip
$(BUILT_KEXEC_BOOT_FILES_PACKAGE) : intermediates := $(intermediates)
$(BUILT_KEXEC_BOOT_FILES_PACKAGE) : \
		zip_root := $(intermediates)/$(name)

built_ota_tools := \
        $(call intermediates-dir-for,EXECUTABLES,applypatch)/applypatch \
        $(call intermediates-dir-for,EXECUTABLES,applypatch_static)/applypatch_static \
        $(call intermediates-dir-for,EXECUTABLES,check_prereq)/check_prereq \
	$(call intermediates-dir-for,EXECUTABLES,sqlite3)/sqlite3 \
        $(call intermediates-dir-for,EXECUTABLES,updater)/updater

$(BUILT_KEXEC_BOOT_FILES_PACKAGE) : PRIVATE_OTA_TOOLS := $(built_ota_tools)
$(BUILT_KEXEC_BOOT_FILES_PACKAGE) : PRIVATE_RECOVERY_API_VERSION := $(RECOVERY_API_VERSION)
$(BUILT_KEXEC_BOOT_FILES_PACKAGE) : \
		$(KEXEC_BOOT_PREREQS) \
		$(PRODUCT_OUT)/recovery.img \
		$(INSTALLED_ANDROID_INFO_TXT_TARGET) \
		$(built_ota_tools) \
		| $(ACP)
	@echo "Package kexec-boot files: $@"
	$(hide) rm -rf $@ $(zip_root)
	$(hide) mkdir -p $(dir $@) $(zip_root)
	@# Copy the recovery fstab
	$(hide) mkdir -p $(zip_root)/RECOVERY/RAMDISK/etc
	$(hide) $(ACP) $(TARGET_RECOVERY_ROOT_OUT)/etc/recovery.fstab \
		$(zip_root)/RECOVERY/RAMDISK/etc
	@# Components of the KEXEC section
	$(hide) mkdir -p $(zip_root)/KEXEC
	$(hide) $(ACP) -p $(KEXEC_BOOT_PREREQS) $(zip_root)/KEXEC/
	@# Contents of the OTA package
	$(hide) mkdir -p $(zip_root)/OTA/bin
	$(hide) $(ACP) $(INSTALLED_ANDROID_INFO_TXT_TARGET) $(zip_root)/OTA/
	$(hide) $(ACP) $(PRIVATE_OTA_TOOLS) $(zip_root)/OTA/bin/
	@# Files required to build an update.zip
	$(hide) mkdir -p $(zip_root)/META
	$(hide) echo "recovery_api_version=$(PRIVATE_RECOVERY_API_VERSION)" > $(zip_root)/META/misc_info.txt
	@# Zip everything up, preserving symlinks
	$(hide) (cd $(zip_root) && zip -qry ../$(notdir $@) .)

# next it's the OTA target
KEXEC_BOOT_OTA_PACKAGE_TARGET := $(PRODUCT_OUT)/kexec-boot.zip
$(KEXEC_BOOT_OTA_PACKAGE_TARGET) : \
		$(BUILT_KEXEC_BOOT_FILES_PACKAGE) \
		$(OTATOOLS) \
		$(SIGNAPK_JAR)
	@echo "Package kexec-boot OTA: $@"
	$(hide) ./device/samsung/d2vzw/kexec-boot/ota_from_target_files -v \
	       -p $(HOST_OUT) \
	       --backup=false \
	       --override_device=auto \
	       $(BUILT_KEXEC_BOOT_FILES_PACKAGE) $@

# we specify KEXEC_BOOT_OTA_PACKAGE_TARGET as a prebuilt ETC file so that if we
# include kexec-boot.zip, then it pulls in all the crap above here
include $(CLEAR_VARS)
# override LOCAL_PATH to . so that our OTA target is picked up
LOCAL_PATH := .
LOCAL_MODULE := kexec-boot.zip
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)
LOCAL_SRC_FILES := $(KEXEC_BOOT_OTA_PACKAGE_TARGET)
include $(BUILD_PREBUILT)

endif # USE_KEXEC = 1
endif # TARGET_DEVICE = d2vzw
