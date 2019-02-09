#!/bin/bash
cd "$( dirname "${BASH_SOURCE[0]}" )"
sudo docker build --rm -f Dockerfile -t rpi3imagebuild:latest .