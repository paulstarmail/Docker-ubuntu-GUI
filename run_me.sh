#!/bin/bash

docker build -t ubuntu-desktop:24.04 . && \
docker run -d --name desktop \
  -p 6080:6080 -p 5901:5901 \
  --shm-size=4g \
  -v /home/hawk/Documents:/home/ubuntu/Documents \
  ubuntu-desktop:24.04
