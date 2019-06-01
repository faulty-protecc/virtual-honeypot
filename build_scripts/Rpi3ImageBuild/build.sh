#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "running from $DIR"

if [[ ! -d $DIR/../../LinuxKernel/out/rpi3-image ]]; then
    mkdir $DIR/../../LinuxKernel/out/rpi3-image
fi

if [[ ! -f $DIR/../../LinuxKernel/out/rpi3-image/20190206-raspberry-pi-3-buster-PREVIEW.img.xz ]]; then
    wget https://people.debian.org/~gwolf/raspberrypi3/20190206/20190206-raspberry-pi-3-buster-PREVIEW.img.xz -P $DIR/../../LinuxKernel/out/rpi3-image
fi
cd $DIR/../../LinuxKernel/out/rpi3-image
unxz 20190206-raspberry-pi-3-buster-PREVIEW.img.xz
cd $DIR

$DIR/../LinuxKernelBuild/build.sh
if [[ -z $(losetup -l | grep 20190206-raspberry-pi-3-buster-PREVIEW.img | cut -f 1 -d " ") ]]; then
    losetup -Pf $DIR/../../LinuxKernel/out/rpi3-image/20190206-raspberry-pi-3-buster-PREVIEW.img
fi
MAIN_LOOP_DEV=$(losetup -l | grep 20190206-raspberry-pi-3-buster-PREVIEW.img | cut -f 1 -d " ")
echo "Main loop dev is $MAIN_LOOP_DEV"
if [[ ! -d "/mnt/tmp_RASPIFIRM" ]]; then 
    mkdir /mnt/tmp_RASPIFIRM
fi
if [[ ! -d "/mnt/tmp_RASPIROOT" ]]; then 
    mkdir /mnt/tmp_RASPIROOT
fi
mount "${MAIN_LOOP_DEV}p1" /mnt/tmp_RASPIFIRM
mount "${MAIN_LOOP_DEV}p2" /mnt/tmp_RASPIROOT
RASPIFIRM_COUNT=$(ls /mnt/tmp_RASPIFIRM/ | wc -l)
RASPIROOT_COUNT=$(ls /mnt/tmp_RASPIROOT/ | wc -l)

if [[ $RASPIFIRM_COUNT -eq 0 ]]; then
    echo "tmp_RASPIFIRM file count is 0!"
    exit 1
fi

if [[ $RASPIROOT_COUNT -eq 0 ]]; then
    echo "tmp_RASPIROOT file count is 0!"
    exit 2
fi

cp $DIR/../../LinuxKernel/out/kernel-obj/arch/arm64/boot/Image /mnt/tmp_RASPIFIRM/linux-4.14.0-malware-detector.img
cp -r $DIR/../../LinuxKernel/out/modules/lib/modules/4.14.0-memacq/ /mnt/tmp_RASPIROOT/lib/modules/
cp $DIR/config.txt $DIR/../../LinuxKernel/out/rpi3-image/firmware_config.txt
cp $DIR/../../LinuxKernel/out/rpi3-image/firmware_config.txt /mnt/tmp_RASPIROOT
cp $DIR/update_initramfs.sh /mnt/tmp_RASPIROOT
echo "if [[ -f /update_initramfs.sh ]]; then /update_initramfs.sh; fi" >> /mnt/tmp_RASPIROOT/root/.bashrc

if [[ ! -f $DIR/../../LinuxKernel/out/rpi3-image/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu.tar.xz ]]; then
    wget https://releases.linaro.org/archive/15.05/components/toolchain/binaries/aarch64-linux-gnu/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu.tar.xz -P $DIR/../../LinuxKernel/out/rpi3-image
fi

cd $DIR/../../LinuxKernel/out/rpi3-image
tar -Jxvf gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu.tar.xz
cd $DIR
$DIR/../../LinuxKernel/out/rpi3-image/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc -o $DIR/../../LinuxKernel/out/rpi3-image/server $DIR/../../LinuxKernel/rasp-hyplet/drivers/md-ramdisk-driver/server.c
cp $DIR/../../LinuxKernel/out/rpi3-image/server /mnt/tmp_RASPIROOT/root/
$DIR/../../LinuxKernel/out/rpi3-image/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc -o $DIR/../../LinuxKernel/out/rpi3-image/activator $DIR/../../HypervisorProtectionActivator/activator.c
cp $DIR/../../LinuxKernel/out/rpi3-image/activator /mnt/tmp_RASPIROOT/root/
cp $DIR/../../util_scripts/create_honeypot /mnt/tmp_RASPIROOT/root/
cp $DIR/../../util_scripts/insmod_in_rpi3 /mnt/tmp_RASPIROOT/root/
$DIR/../LinuxKernelBuild/build_dtb.sh
cp $DIR/../../LinuxKernel/out/dtb/bcm2710-rpi-3-b-plus.dtb /mnt/tmp_RASPIFIRM/
umount /mnt/tmp_RASPIFIRM
umount /mnt/tmp_RASPIROOT
losetup -d $MAIN_LOOP_DEV
cp $DIR/../../LinuxKernel/out/rpi3-image/20190206-raspberry-pi-3-buster-PREVIEW.img $DIR/../../LinuxKernel/out/rpi3-image/rpi3.img