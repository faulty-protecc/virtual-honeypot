#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "running from $DIR"
sudo docker run -v $DIR/../../LinuxKernel/out/modules:/root/modules -v $DIR/../../LinuxKernel/out/kernel-obj:/root/kernel-obj -d --name rpi3-image-build rpi3imagebuild rpi3imagebuild:latest 2>/dev/null

if [ $? != 0 ]; then
    sudo docker start rpi3-image-build
fi

sudo rm -rf $DIR/../../LinuxKernel/out/*/*
$DIR/../LinuxKernelBuild/build.sh
sudo docker exec rpi3-image-build wget https://people.debian.org/~gwolf/raspberrypi3/20190206/20190206-raspberry-pi-3-buster-PREVIEW.img.xz
sudo docker exec rpi3-image-build unxz 20190206-raspberry-pi-3-buster-PREVIEW.img.xz
sudo mount -o loop,offset=1048576 20190206-raspberry-pi-3-buster-PREVIEW.img /media/RASPIFIRM
sudo docker stop rpi3-image-build