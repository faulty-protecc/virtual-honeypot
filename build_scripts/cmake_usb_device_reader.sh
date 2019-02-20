#!/bin/bash
cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Debug -S USBDeviceReader -B USBDeviceReader/cmake-build-debug
make -j 8 -C USBDeviceReader/cmake-build-debug/
