#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "running from $DIR"
sudo docker run --privileged -v $DIR/../../LinuxKernel/out/modules:/root/modules -v $DIR/../../LinuxKernel/out/kernel-obj:/root/kernel-obj -d --name rpi3-image-build rpi3imagebuild rpi3imagebuild:latest 2>/dev/null

if [ $? != 0 ]; then
    sudo docker start rpi3-image-build
fi

$DIR/../LinuxKernelBuild/build.sh
sudo docker exec rpi3-image-build wget https://people.debian.org/~gwolf/raspberrypi3/20190206/20190206-raspberry-pi-3-buster-PREVIEW.img.xz
sudo docker exec rpi3-image-build unxz 20190206-raspberry-pi-3-buster-PREVIEW.img.xz
if [[ -z $(sudo docker exec rpi3-image-build losetup -l | grep 20190206-raspberry-pi-3-buster-PREVIEW.img | cut -f 1 -d " ") ]]; then
    sudo docker exec rpi3-image-build losetup -Pf 20190206-raspberry-pi-3-buster-PREVIEW.img
fi
MAIN_LOOP_DEV=$(sudo docker exec rpi3-image-build losetup -l | grep 20190206-raspberry-pi-3-buster-PREVIEW.img | cut -f 1 -d " ")
echo "Main loop dev is $MAIN_LOOP_DEV"
sudo docker exec rpi3-image-build /bin/bash -c 'if [[ ! -d "/mnt/RASPIFIRM" ]]; then mkdir /mnt/RASPIFIRM; fi'
sudo docker exec rpi3-image-build /bin/bash -c 'if [[ ! -d "/mnt/RASPIROOT" ]]; then mkdir /mnt/RASPIROOT; fi'
sudo docker exec rpi3-image-build mount ${MAIN_LOOP_DEV}p1 /mnt/RASPIFIRM/
sudo docker exec rpi3-image-build mount ${MAIN_LOOP_DEV}p2 /mnt/RASPIROOT/
sudo docker stop rpi3-image-build