#!/bin/bash

thermal_cmd() {

    ui_header

    printf "${white}thermal information${reset}\n\n"

    for zone in /sys/class/thermal/thermal_zone*; do

        if [ -f "$zone/temp" ]; then

            name=$(cat "$zone/type" 2>/dev/null)
            temp=$(cat "$zone/temp")

            celsius=$((temp / 1000))

            printf " %-15s : %s°c\n" "$name" "$celsius"

        fi

    done

    echo
}