[![lroguet/rpi-home-assistant](https://img.shields.io/docker/pulls/lroguet/rpi-home-assistant.svg)](https://hub.docker.com/r/lroguet/rpi-home-assistant/)
[![lroguet/rpi-home-assistant](https://images.microbadger.com/badges/version/lroguet/rpi-home-assistant.svg)](https://hub.docker.com/r/lroguet/rpi-home-assistant/) [![lroguet/rpi-home-assistant](https://images.microbadger.com/badges/image/lroguet/rpi-home-assistant.svg)](https://hub.docker.com/r/lroguet/rpi-home-assistant/)

# Home Assistant Docker image for Raspberry Pi

## Description
Generate a Dockerfile, build a Raspberry Pi compatible Docker image with [Home Assistant](https://home-assistant.io/) and push it to https://hub.docker.com.

## Build & push

*Note. You may want to update the `DOCKER_IMAGE_NAME` variable at the beginning of the `build.sh` script to build a custom Docker image and push it to your own Docker repository.*

### Latest version
To build a Docker image with the version of Home Assistant found at https://pypi.python.org/pypi/homeassistant/json just run `./build.sh`

*Note. This build case requires you have 'jq' installed.*

### Specific version
To build a Docker image with a specific version of Home Assistant run `./build.sh x.y.z` (`./build.sh 0.23.1` for example).

## Simple usage
`docker run -d --name hass -v /etc/localtime:/etc/localtime:ro lroguet/rpi-home-assistant:latest`

## Additional parameters
### Persistent configuration
Create a folder where you want to store your Home Assistant configuration (/home/pi/home-assistant/configuration for example) and add this data volume to the container using the `-v` flag.

`docker run -d --name hass -v /etc/localtime:/etc/localtime:ro -v /home/pi/home-assistant/configuration:/config lroguet/rpi-home-assistant:latest`

### Enable uPnP discovery
In order to enable the discovery feature (for devices such as Google Chromecasts, Belkin WeMo switches, Sonos speakers, ...) Home Assistant must run on the same network as the devices. The `--net=host` Docker option is needed.

`docker run -d --name hass --net=host -v /etc/localtime:/etc/localtime:ro lroguet/rpi-home-assistant:latest`

## Usage
### One-liner
`docker run -d --name hass --net=host -v /etc/localtime:/etc/localtime:ro -v /home/pi/home-assistant/configuration:/config lroguet/rpi-home-assistant:latest`

### With Docker Compose

```yml
# docker-compose.yml
hass:
  container_name: hass
  image: lroguet/rpi-home-assistant:latest
  net: host
  volumes:
    - /home/pi/home-assistant/configuration:/config
    - /etc/localtime:/etc/localtime:ro
```

`docker-compose run -d --service-ports hass`

## Show some love
If you find `lroguet/rpi-home-assistant` useful please consider making a donation.

Bitcoin (BTC). `1JU59RHfmdEZCPgetf3rjrWU8JQiFeGPaL`   
Ethereum (ETH). `0x5BbaAb38Be768F281Bc08Ee380735FC5C8cc5CD0`

## Links
* [Home Assistant, Docker & a Raspberry Pi](https://fourteenislands.io/home-assistant-docker-and-a-raspberry-pi/)
* [Docker public repository](https://hub.docker.com/r/lroguet/rpi-home-assistant/)
* [Home Assistant](https://home-assistant.io/)
