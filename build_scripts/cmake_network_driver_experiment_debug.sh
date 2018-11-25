#!/bin/bash
cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Debug -S NetworkDriverExperiment -B NetworkDriverExperiment/cmake-build-debug
make -j 8 -C NetworkDriverExperiment/cmake-build-debug/