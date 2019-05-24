#!/bin/bash
set -e
update-initramfs -k 4.14.0-hyplet -c
cp /firmware_config.txt /boot/firmware/config.txt

# self destruct source script
rm $0

reboot