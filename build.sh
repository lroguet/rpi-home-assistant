#!/bin/bash

HA_LATEST=false

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
   HA_VERSION="$(curl 'https://pypi.python.org/pypi/homeassistant/json' | jq '.info.version' | tr -d '"')"
   HA_LATEST=true
   log "Docker image with Home Assistant 'latest' (version $HA_VERSION)" 
fi

## #####################################################################
## For hourly (not parameterized) builds (crontab)
## Do nothing: we're trying to build & push the same version again
## #####################################################################
if [ "$HA_LATEST" = true ] && [ "$HA_VERSION" = "$_HA_VERSION" ]; then
   log "Docker image with Home Assistant $HA_VERSION has already been built & pushed"
   log ">>--------------------->>"
   exit 0
fi

## #####################################################################
## Generate the Dockerfile
## #####################################################################
cat << _EOF_ > Dockerfile
FROM resin/rpi-raspbian
MAINTAINER Ludovic Roguet <code@fourteenislands.io>

# Base layer
ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Install some packages
# #1: 20160803 - Added net-tools and nmap for https://home-assistant.io/components/device_tracker.nmap_scanner/
# #2: 20161021 - Added ssh for https://home-assistant.io/components/device_tracker.asuswrt/ 
RUN apt-get update && \
    apt-get install --no-install-recommends build-essential net-tools nmap python3-dev python3-pip ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mouting point for the user's configuration
VOLUME /config

# Start Home Assistant
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]

# Install Home Assistant
RUN pip3 install homeassistant==$HA_VERSION
_EOF_

## #####################################################################
## Build the Docker image, tag and push to https://hub.docker.com/
## #####################################################################
log "Building lroguet/rpi-home-assistant:$HA_VERSION"
docker build -t lroguet/rpi-home-assistant:$HA_VERSION .

log "Pushing lroguet/rpi-home-assistant:$HA_VERSION"
docker push lroguet/rpi-home-assistant:$HA_VERSION

if [ "$HA_LATEST" = true ]; then
   log "Tagging lroguet/rpi-home-assistant:$HA_VERSION with latest"
   docker tag lroguet/rpi-home-assistant:$HA_VERSION lroguet/rpi-home-assistant:latest
   log "Pushing lroguet/rpi-home-assistant:latest"
   docker push lroguet/rpi-home-assistant:latest
   echo $HA_VERSION > /var/log/home-assistant/docker-build.version
fi

log ">>--------------------->>"
