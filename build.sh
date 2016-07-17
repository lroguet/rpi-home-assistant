#!/bin/bash

## Home Assistant version
if [ "$1" != "" ]; then
   # Provided as an argument
   echo "Building Docker image with Home Assistant $1"
   HA_VERSION=$1
else
   echo "Building Docker image with Home Assistant 'latest' version" 
   HA_VERSION="$(curl 'https://pypi.python.org/pypi/homeassistant/json' | jq '.info.version' | tr -d '"')"
fi

## Generate the Dockerfile
cat << _EOF_ > Dockerfile
FROM resin/rpi-raspbian
MAINTAINER Ludovic Roguet <code@fourteenislands.io>

# Base layer
ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Install some packages
RUN apt-get update && \
    apt-get install build-essential python3-dev python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mouting point for the user's configuration
VOLUME /config

# Start Home Assistant
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]

# Install Home Assistant
RUN pip3 install homeassistant==$HA_VERSION
_EOF_

## Build the Docker image, tag and push to https://hub.docker.com/
docker build -t lroguet/rpi-home-assistant:$HA_VERSION .
docker push lroguet/rpi-home-assistant:$HA_VERSION
