#!/bin/bash

monitor_thermal() {

    printf "${white}thermal subsystem${reset}\n\n"

    hottest=0

    for zone in /sys/class/thermal/thermal_zone*; do

        if [ -f "$zone/temp" ]; then

            name=$(cat "$zone/type" 2>/dev/null)

            temp=$(cat "$zone/temp")

            celsius=$((temp / 1000))

            if [ "$celsius" -gt "$hottest" ]; then
                hottest="$celsius"
            fi

            printf " %-14s : %s°c\n" "$name" "$celsius"

        fi

    done

    echo

    printf " hottest zone   : %s°c\n" "$hottest"

    if [ "$hottest" -ge 85 ]; then
        printf "${red} thermal state  : critical${reset}\n"
    elif [ "$hottest" -ge 70 ]; then
        printf "${yellow} thermal state  : warm${reset}\n"
    else
        printf "${green} thermal state  : normal${reset}\n"
    fi

    echo
}