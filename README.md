# Home Assistant Docker image for Raspberry Pi
## Description
Simple script to generate a Dockerfile and  build a Raspberry Pi compatible Docker image with [Home Assistant](https://home-assistant.io/).

## Simple usage
`docker run -d --name home_assistant -v /etc/localtime:/etc/localtime:ro lroguet/rpi-home-assistant:latest`

## Additional parameters
### Persistent configuration
Create a folder where you want to store your Home Assistant configuration (/home/pi/home-assistant/configuration for example) and add this data volume to the container using the `-v` flag.

`docker run -d --name home_assistant -v /etc/localtime:/etc/localtime:ro -v /home/pi/home-assistant/configuration:/config lroguet/rpi-home-assistant:latest`

### Enable uPnP discovery
In order to enable the discovery feature (for devices such as Google Chromecasts, Belkin WeMo switches, Sonos speakers, ...) Home Assistant must run on the same network as the devices. The `--net=host` Docker option is needed.

`docker run -d --name home_assistant --net=host -v /etc/localtime:/etc/localtime:ro lroguet/rpi-home-assistant:latest`

## Usage
### One-liner
`docker run -d --name home_assistant --net=host -v /etc/localtime:/etc/localtime:ro -v /home/pi/home-assistant/configuration:/config lroguet/rpi-home-assistant:latest`

### With Docker Compose

```yml
# docker-compose.yml
ha:
  container_name: ha
  image: lroguet/rpi-home-assistant:latest
  net: host
  volumes:
    - /home/pi/home-assistant/configuration:/config
    - /etc/localtime:/etc/localtime:ro
```

`docker-compose run -d --service-ports ha`

## Links
* [Docker public repository](https://hub.docker.com/r/lroguet/rpi-home-assistant/)
* [Home Assistant](https://home-assistant.io/)
