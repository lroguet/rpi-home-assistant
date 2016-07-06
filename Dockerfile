FROM resin/rpi-raspbian
MAINTAINER Ludovic Roguet <code@fourteenislands.io>

ENV HA_VERSION 0.23.1

ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Install some packages
RUN apt-get update && \
    apt-get install build-essential python3-dev python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Home Assistant
RUN pip3 install homeassistant==$HA_VERSION

# Mouting point for the user's configuration
VOLUME /config

# Start Home Assistant
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
