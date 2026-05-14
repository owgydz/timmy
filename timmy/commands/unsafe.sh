#!/bin/bash

unsafe_enable() {

    require_root

    clear

    printf "${red}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#                  UNSAFE MODE WARNING                     #\n"
    printf "#                                                           #\n"
    printf "#   THIS MODE CAN PERMANENTLY BRICK YOUR DEVICE.           #\n"
    printf "#                                                           #\n"
    printf "#############################################################\n"
    printf "${reset}\n\n"

    printf "${yellow}type 'i understand' to continue:${reset} "

    read confirm

    if [ "$confirm" != "i understand" ]; then
        ui_fail "unsafe mode aborted"
        exit 1
    fi

    echo "unsafe=enabled" > "$config_dir/unsafe.conf"

    ok "unsafe mode enabled"
}

unsafe_disable() {

    require_root

    rm -f "$config_dir/unsafe.conf"

    ok "unsafe mode disabled"
}

unsafe_status() {

    ui_header

    if [ -f "$config_dir/unsafe.conf" ]; then
        printf "${red}unsafe mode enabled${reset}\n\n"
    else
        printf "${green}unsafe mode disabled${reset}\n\n"
    fi
}