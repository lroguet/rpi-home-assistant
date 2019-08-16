#!/bin/bash

HA_LATEST=false
DOCKER_IMAGE_NAME="lroguet/rpi-home-assistant"
RASPBIAN_IMAGE_NAME="balenalib/rpi-raspbian"
RASPBIAN_RELEASE="buster"

log() {
   now=$(date +"%Y%m%d-%H%M%S")
   echo "$now - $*" >> /var/log/home-assistant/docker-build.log
}

log ">>--------------------->>"

## #####################################################################
## Home Assistant version
## #####################################################################
if [ "$1" != "" ]; then
   # Provided as an argument
   HA_VERSION=$1
   log "Docker image with Home Assistant $HA_VERSION"
else
   _HA_VERSION="$(cat /var/log/home-assistant/docker-build.version)"
   HA_VERSION="$(curl 'https://pypi.org/pypi/homeassistant/json' | jq '.info.version' | tr -d '"')"
   HA_LATEST=true
   log "Docker image with Home Assistant 'latest' (version $HA_VERSION)"
fi

## #####################################################################
## For hourly (not parameterized) builds (crontab)
## Do nothing: we're trying to build & push the same version again
## #####################################################################
if [ "$HA_LATEST" == true ] && [ "$HA_VERSION" == "$_HA_VERSION" ]; then
   log "Docker image with Home Assistant $HA_VERSION has already been built & pushed"
   log ">>--------------------->>"
   exit 0
fi

## #####################################################################
## Generate the Dockerfile
## #####################################################################
cat << _EOF_ > Dockerfile
FROM $RASPBIAN_IMAGE_NAME:$RASPBIAN_RELEASE
MAINTAINER Ludovic Roguet <code@fourteenislands.io>

# Base layer
ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Install some packages
# #1:   20160803 - Added net-tools and nmap for https://home-assistant.io/components/device_tracker.nmap_scanner/
# #3:   20161021 - Added ssh for https://home-assistant.io/components/device_tracker.asuswrt/
# #8:   20170313 - Added ping for https://home-assistant.io/components/switch.wake_on_lan/
# #10:  20170328 - Added libffi-dev, libpython-dev and libssl-dev for https://home-assistant.io/components/notify.html5/
# #11:	20170628 - Added libud3v-dev for https://home-assistant.io/components/zwave/
# #14: 	20170802 - Added bluetooth and libbluetooth-dev for https://home-assistant.io/components/device_tracker.bluetooth_tracker/
# #17:	20171203 - Added autoconf for https://home-assistant.io/components/tradfri/
# #29:  20181208 - Added libusb-1.0-0 and android-tools-adb for https://www.home-assistant.io/components/media_player.firetv/
RUN apt-get update && \
    apt-get install --no-install-recommends \
      android-tools-adb \
      autoconf \
      build-essential python3-dev python3-pip python3-setuptools \
      libcups2-dev \
      libffi-dev libpython-dev libssl-dev \
      libudev-dev \
      libusb-1.0-0 \
      bluetooth libbluetooth-dev \
      net-tools nmap \
      iputils-ping \
      ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mouting point for the user's configuration
VOLUME /config

# Start Home Assistant
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]

# Install Home Assistant
RUN pip3 install wheel
RUN pip3 install homeassistant==$HA_VERSION
_EOF_

## #####################################################################
## Build the Docker image, tag and push to https://hub.docker.com/
## #####################################################################
log "Building $DOCKER_IMAGE_NAME:$HA_VERSION"
## Force-pull the base image
docker pull $RASPBIAN_IMAGE_NAME:$RASPBIAN_RELEASE
docker build -t $DOCKER_IMAGE_NAME:$HA_VERSION .

log "Pushing $DOCKER_IMAGE_NAME:$HA_VERSION"
docker push $DOCKER_IMAGE_NAME:$HA_VERSION

if [ "$HA_LATEST" = true ]; then
   log "Tagging $DOCKER_IMAGE_NAME:$HA_VERSION with latest"
   docker tag $DOCKER_IMAGE_NAME:$HA_VERSION $DOCKER_IMAGE_NAME:latest
   log "Pushing $DOCKER_IMAGE_NAME:latest"
   docker push $DOCKER_IMAGE_NAME:latest
   echo $HA_VERSION > /var/log/home-assistant/docker-build.version
   log "Removing $DOCKER_IMAGE_NAME:latest locally"
   docker rmi -f $DOCKER_IMAGE_NAME:latest
fi

log "Removing $DOCKER_IMAGE_NAME:$HA_VERSION locally"
docker rmi -f $DOCKER_IMAGE_NAME:$HA_VERSION

## Clean-up Docker environment
docker ps -aq --no-trunc | xargs docker rm
docker images -q --filter dangling=true | xargs docker rmi

log ">>--------------------->>"
