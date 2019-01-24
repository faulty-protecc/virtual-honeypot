FROM ubuntu:bionic
RUN apt-get update
RUN apt-get -y install libssl-dev wget tar xz-utils make gcc bc
RUN wget --directory-prefix=/opt https://releases.linaro.org/archive/15.05/components/toolchain/binaries/aarch64-linux-gnu/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu.tar.xz
RUN cd /opt && tar -Jxvf gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu.tar.xz && rm gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu.tar.xz
ENTRYPOINT tail -f /dev/null