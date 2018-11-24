cmake_minimum_required(VERSION 3.12)
project(NetworkDriverExperiment C)

set(CMAKE_C_STANDARD 99)

add_executable(NetworkDriverExperiment main.c)
target_link_libraries(NetworkDriverExperiment usb-1.0)