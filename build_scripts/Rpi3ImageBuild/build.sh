#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "running from $DIR"
docker run --privileged -v $DIR/../../LinuxKernel/out/modules:/root/modules -v $DIR/../../LinuxKernel/out/kernel-obj:/root/kernel-obj -d --name rpi3-image-build rpi3imagebuild rpi3imagebuild:latest 2>/dev/null

if [ $? != 0 ]; then
    docker start rpi3-image-build
fi

$DIR/../LinuxKernelBuild/build.sh
if [[ -z $(sudo docker exec rpi3-image-build losetup -l | grep 20190206-raspberry-pi-3-buster-PREVIEW.img | cut -f 1 -d " ") ]]; then
    docker exec rpi3-image-build losetup -Pf 20190206-raspberry-pi-3-buster-PREVIEW.img
fi
MAIN_LOOP_DEV=$(sudo docker exec rpi3-image-build losetup -l | grep 20190206-raspberry-pi-3-buster-PREVIEW.img | cut -f 1 -d " ")
echo "Main loop dev is $MAIN_LOOP_DEV"
docker exec rpi3-image-build /bin/bash -c 'if [[ ! -d "/mnt/RASPIFIRM" ]]; then mkdir /mnt/RASPIFIRM; fi'
docker exec rpi3-image-build /bin/bash -c 'if [[ ! -d "/mnt/RASPIROOT" ]]; then mkdir /mnt/RASPIROOT; fi'
docker exec rpi3-image-build mount "${MAIN_LOOP_DEV}p1" /mnt/RASPIFIRM/
docker exec rpi3-image-build mount "${MAIN_LOOP_DEV}p2" /mnt/RASPIROOT/
RASPIFIRM_COUNT=$(docker exec rpi3-image-build ls /mnt/RASPIFIRM/ | wc -l)
RASPIROOT_COUNT=$(docker exec rpi3-image-build ls /mnt/RASPIROOT/ | wc -l)

if [[ $RASPIFIRM_COUNT -eq 0 ]]; then
    echo "RASPIFIRM file count is 0!"
    exit 1
fi

if [[ $RASPIROOT_COUNT -eq 0 ]]; then
    echo "RASPIROOT file count is 0!"
    exit 2
fi

docker exec rpi3-image-build cp $DIR/../../LinuxKernel/out/kernel-obj/arch/arm64/boot/Image /mnt/RASPIFIRM/linux-4.14.0-malware-detector.img
docker exec rpi3-image-build cp -r $DIR/../../LinuxKernel/out/modules/lib/modules/4.14.0-hyplet/ /mnt/RASPIROOT/lib/modules/
docker exec rpi3-image-build chroot /mnt/RASPIROOT
docker exec rpi3-image-build update-initramfs -k 4.14.0-hyplet -c
docker stop rpi3-image-build