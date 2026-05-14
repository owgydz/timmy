#!/bin/bash

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
cyan="\e[36m"
white="\e[97m"
reset="\e[0m"

ui_line() {

    printf "${blue}====================================================${reset}\n"
}

ui_header() {

    clear

    ui_line

    printf "${cyan} timmy v%s ${reset}\n" "$version"

    ui_line
}

ui_loading() {

    message="$1"

    printf "${yellow}[timmy]${reset} %s" "$message"

    for i in {1..3}; do
        sleep 0.15
        printf "."
    done

    printf "\n"

    log_info "$message"
}

ui_ok() {

    printf "${green}[ ok ]${reset} %s\n" "$1"

    log_info "$1"
}

ui_warn() {

    printf "${yellow}[warn]${reset} %s\n" "$1"

    log_warn "$1"
}

ui_fail() {

    printf "${red}[fail]${reset} %s\n" "$1"

    log_error "$1"
}