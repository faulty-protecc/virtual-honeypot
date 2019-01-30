# virtual-honeypot
Experimental simulated honeypot with USB-CDC and regular USB3 DOKs

# Prerequisites
- Docker
- Ubuntu 18.04 (or later)

# Building steps for building the microkernel
This repository contains
- source code of the microkernel we use, coppied tepmorarily from [this gitlab repo](https://git.scipio.org/raziebe/pi3-public)
- some libusb examples (internally used to analyze the structure of usb and other block devices, depicted by libusb)
- docker image that installs ubuntu (bionic).
The basic build process is running the [`build_docker_image.sh`](https://github.com/deankevorkian/virtual-honeypot/blob/master/build_scripts/LinuxKernelBuild/build_docker_image.sh) script. The script builds a docker image which in place installs all the prerequisites for building the kernel (on top of Ubuntu bionic).
