#
# Copyright (C) 2011 The CyanogenMod Project
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
#

## (2) Also get non-open-source specific aspects if available
$(call inherit-product-if-exists, vendor/samsung/d2vzw/d2vzw-vendor.mk)

## overlays
DEVICE_PACKAGE_OVERLAYS += device/samsung/d2vzw/overlay

# Kernel and modules
ifeq ($(TARGET_PREBUILT_KERNEL),)
    LOCAL_KERNEL := device/samsung/d2vzw/prebuilt/kernel
else
    LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_KERNEL):kernel \
    device/samsung/d2vzw/modules/ansi_cprng.ko:system/lib/modules/ansi_cprng.ko \
    device/samsung/d2vzw/modules/btlock.ko:system/lib/modules/btlock.ko \
    device/samsung/d2vzw/modules/dhd.ko:system/lib/modules/dhd.ko \
    device/samsung/d2vzw/modules/dma_test.ko:system/lib/modules/dma_test.ko \
    device/samsung/d2vzw/modules/exfat_core.ko:system/lib/modules/exfat_core.ko \
	device/samsung/d2vzw/modules/exfat_fs.ko:system/lib/modules/exfat_fs.ko \
    device/samsung/d2vzw/modules/msm-buspm-dev.ko:system/lib/modules/msm-buspm-dev.ko \
    device/samsung/d2vzw/modules/qce40.ko:system/lib/modules/qce40.ko \
    device/samsung/d2vzw/modules/qcedev.ko:system/lib/modules/qcedev.ko \
    device/samsung/d2vzw/modules/qcrypto.ko:system/lib/modules/qcrypto.ko \
    device/samsung/d2vzw/modules/reset_modem.ko:system/lib/modules/reset_modem.ko \
    device/samsung/d2vzw/modules/scsi_wait_scan.ko:system/lib/modules/scsi_wait_scan.ko \
    device/samsung/d2vzw/modules/spidev.ko:system/lib/modules/spidev.ko

# Inherit from d2-common
$(call inherit-product, device/samsung/d2-common/d2-common.mk)

$(call inherit-product-if-exists, vendor/samsung/d2vzw/d2vzw-vendor.mk)
