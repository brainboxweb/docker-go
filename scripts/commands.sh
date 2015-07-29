#!/bin/sh

function write_error () {
    color="\e[0;31m"
    write_line "$1" $color
}

function write_primary () {
    color="\e[1;36m"
    write_line "\n$1" $color
}

function write_success () {
    color="\e[1;32m"
    write_line "\n$1\n" $color
}

function write_line () {
    default_color="\e[0m"
    printf "$2$1\n$default_color"
}

function remove_containers () {
    containers="$(docker ps | grep $1 |  awk '{print $1}')"
    if [ -n "$containers" ]; then
        write_line "Stopping containers"
        docker stop "$containers"
    fi
    containers="$(docker ps -a | grep $1 |  awk '{print $1}')"
    if [ -n "$containers" ]; then
        write_line "Removing containers"
        docker rm "$containers"
    fi
}
