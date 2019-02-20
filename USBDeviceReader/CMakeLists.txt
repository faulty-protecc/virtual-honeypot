cmake_minimum_required(VERSION 3.12)
project(USBDeviceReader C)

set(CMAKE_C_STANDARD 99)

add_executable(USBDeviceReader usb-device-reader.c)
target_link_libraries(USBDeviceReader)