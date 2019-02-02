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

# Creating an image for the Raspberry Pi 3 Model B+
- First, build the microkernel from [here](#building-steps-for-building-the-microkernel)
- Download a [Debian for Raspberry Pi 3 image](https://people.debian.org/~gwolf/raspberrypi3/20181204/20181204-raspberry-pi-3-buster-PREVIEW.img.xz)
- Wipe your SD card clean if it isn't clean already (you can you use gparted for that).
- Run the following command:
```bash
xzcat 20181204-raspberry-pi-3-buster-PREVIEW.img.xz | dd of=/dev/sdX bs=64k oflag=dsync status=progress
```
- **Notice:** You need to replace /dev/sdX with the device that you are writing to. Make sure that it is actually the SD card, so you do not accidentally corrupt your own file system!
- Copy LinuxKernel/out/kernel-obj/arch/arm64/boot/Image to the RASPIFIRM mount and give it a meaningful name (eg. linux-4.14.0-hyplets.img)
- Copy the modules from LinuxKernel/out/modules/lib/modules/ to /lib/modules on the RASPIROOT mount
- Now take out the SD card from your computer and put it in the Raspberry Pi
- On the Raspberry Pi run `Run initramfs -k <your-kernel-module-version> -c` (eg. `Run initramfs -k 4.14.0-hyplet -c`)
- Still inside the Raspberry Pi 3, Copy your image from /boot/firmware to /boot (this is the image from LinuxKernel/out/kernel-obj/arch/arm64/boot/)
- Now, on the Rapsberry Pi 3, write the following on the config.txt (make sure to comment out any duplicate kernel and initramfs parameters with #):
```
kernel=linux-4.14.0-hyplets.img
initramfs initrd.img-4.14.0-hyplet
```
- Now reboot the Raspberry Pi and login with root as the username and "raspberry" as the password.
- Run `uname -r` and you should see your custom kernel name.
