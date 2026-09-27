#!/usr/bin/env bash

set -ueo pipefail

which fastboot > /dev/null

device=oneplus-fajita
product_name=sdm845
has_slots=true
esp_part=system_b
root_part=userdata

echo ">>> Flashing $device"

echo '>>> Waiting for device to appear in fastboot...'
fastboot getvar product 2>&1 | grep "$product_name"

if [ "$has_slots" = "true" ]; then
    echo '>>> (1/5) Erasing DTBO'
    fastboot erase dtbo_a
    fastboot erase dtbo_b
    echo '>>> (2/5) Flashing U-Boot'
    fastboot flash boot images/u-boot-$device.img --slot=all
else
    echo '>>> (1/5) Erasing DTBO'
    fastboot erase dtbo
    echo '>>> (2/5) Flashing U-Boot'
    fastboot flash boot images/u-boot-$device.img
fi

echo ">>> (3/5) Flashing fedora_esp.raw into $esp_part"
fastboot flash $esp_part images/fedora_esp.raw

echo ">>> (4/5) Flashing fedora_rootfs.raw into $root_part"
fastboot flash $root_part images/fedora_rootfs.raw

echo '>>> (5/5) Writing to disk and rebooting (this may take a while, DO NOT DISCONNECT THE DEVICE)'
fastboot reboot
