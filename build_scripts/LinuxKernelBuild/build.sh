#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "running from $DIR"
sudo docker run -v $DIR/../../LinuxKernel/linux-4.14.0-hyplet:/root/linux-source -v $DIR/../../LinuxKernel/out/modules:/root/modules -v $DIR/../../LinuxKernel/out/kernel-obj:/root/kernel-obj -d --name linux-kernel-build linuxkernelbuild linuxkernelbuild:latest 2>/dev/null

if [ $? != 0 ]; then
    sudo docker start linux-kernel-build
fi

sudo rm -rf $DIR/../../LinuxKernel/out/*/*
sudo docker exec --workdir /root/linux-source linux-kernel-build cp config_4.14.0-hyplet /root/kernel-obj/.config
sudo docker exec --workdir /root/linux-source linux-kernel-build make -j8 ARCH=arm64 CROSS_COMPILE=/opt/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu- config_4.14.0-hyplet INSTALL_MOD_PATH=/root/modules O=/root/kernel-obj
sudo docker exec --workdir /root/linux-source linux-kernel-build make -j8 ARCH=arm64 CROSS_COMPILE=/opt/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu- INSTALL_MOD_PATH=/root/modules O=/root/kernel-obj
sudo docker exec --workdir /root/linux-source linux-kernel-build make -j8 ARCH=arm64 CROSS_COMPILE=/opt/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=/root/modules O=/root/kernel-obj

sudo docker stop linux-kernel-build