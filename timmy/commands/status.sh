#!/bin/bash

status_cmd() {

    ui_header

    log_info "displaying system status"

    printf "${white}system status${reset}\n\n"

    printf " hostname          : %s\n" "$(hostname)"
    printf " uptime            : %s\n" "$(uptime -p)"
    printf " kernel            : %s\n" "$(uname -r)"
    printf " memory            : %s\n" "$(free -h | awk '/Mem:/ {print $3 " / " $2}')"

    if [ -d /sys/class/power_supply/BAT0 ]; then
        printf " battery           : %s%%\n" "$(cat /sys/class/power_supply/BAT0/capacity)"
    fi

    echo
}