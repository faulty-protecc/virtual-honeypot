#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -d $DIR/../../LinuxKernel/out/dtb ]; then 
    rm -rf $DIR/../../LinuxKernel/out/dtb
fi
mkdir $DIR/../../LinuxKernel/out/dtb
sudo dtc -o $DIR/../../LinuxKernel/out/dtb/bcm2710-rpi-3-b-plus.dtb $DIR/../../LinuxKernel/dtree_dts/bcm2710-rpi-3-b-plus.dts
sudo dtc -o $DIR/../../LinuxKernel/out/dtb/bcm2837-rpi-3-b.dtb $DIR/../../LinuxKernel/dtree_dts/bcm2837-rpi-3-b.dts