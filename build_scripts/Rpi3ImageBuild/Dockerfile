FROM ubuntu:bionic
RUN apt-get update
RUN apt-get -y install libssl-dev wget tar xz-utils
RUN wget https://people.debian.org/~gwolf/raspberrypi3/20190206/20190206-raspberry-pi-3-buster-PREVIEW.img.xz
RUN unxz 20190206-raspberry-pi-3-buster-PREVIEW.img.xz
ENTRYPOINT tail -f /dev/null