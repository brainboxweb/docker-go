#!/bin/sh

docker stop $(docker ps -a | awk '{if (NR!=1) {print $1}}')
docker rm $(docker ps -a | awk '{if (NR!=1) {print $1}}')
docker rmi $(docker images | awk '{if (NR!=1) {print $3}}')