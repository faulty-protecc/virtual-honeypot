# virtual-honeypot
Experimental simulated honeypot with USB-CDC and regular USB3 DOKs

# Prerequisites
- Docker
- Ubuntu 18.04 (or later)

# Building steps for building the microkernel
This repository contains
- Source code of the microkernel we use, copied tepmorarily from [this gitlab repo](https://git.scipio.org/raziebe/pi3-public)
- Some libusb examples (internally used to analyze the structure of usb and other block devices, depicted by libusb)
- Docker image that installs ubuntu (bionic)
The basic build process is running the [`build_docker_image.sh`](https://github.com/deankevorkian/virtual-honeypot/blob/master/build_scripts/LinuxKernelBuild/build_docker_image.sh) script. The script builds a docker image which in place installs all the prerequisites for building the kernel (on top of Ubuntu bionic)
- Run [build.sh](https://github.com/deankevorkian/virtual-honeypot/blob/master/build_scripts/LinuxKernelBuild/build.sh) in order to build the kernel

# Creating an image for the Raspberry Pi 3 Model B+
- First, build the microkernel from [here](#building-steps-for-building-the-microkernel)
- Now, build an image to load to the sd card [here](https://github.com/deankevorkian/virtual-honeypot/blob/master/build_scripts/Rpi3ImageBuild/build.sh) (run it as root)
- In the end, you will have an "rpi3.img" file in "LinuxKernel/out/rpi3-image"
- Next, run the following command (remember to put the path to rpi3.img and replace /dev/sdX with the SD card device you will load to:
`dd if=<path-to-rpi3.mg> of=/dev/sdX bs=64k oflag=dsync status=progress`
- Boot the Raspberry Pi with the SD card. It will update-initramfs and then reboot with the new kernel
- Run `uname -r` and you should see your custom kernel name
