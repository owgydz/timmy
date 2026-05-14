#!/bin/bash

dashboard_cmd() {

    log_info "dashboard launched"

    while true; do

        clear

        printf "${cyan}"
        printf "╔════════════════════════════════════╗\n"
        printf "║         timmy dashboard           ║\n"
        printf "╠════════════════════════════════════╣\n"
        printf "${reset}"

        printf " hostname   : %s\n" "$(hostname)"
        printf " kernel     : %s\n" "$(uname -r)"
        printf " memory     : %s\n" "$(free -h | awk '/Mem:/ {print $3 "/" $2}')"

        if [ -d /sys/class/power_supply/BAT0 ]; then
            printf " battery    : %s%%\n" "$(cat /sys/class/power_supply/BAT0/capacity)"
        fi

        echo
        printf " press ctrl+c to exit\n"

        sleep 2
    done
}