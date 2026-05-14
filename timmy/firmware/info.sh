#!/bin/bash

firmware_info() {

    ui_header

    log_info "reading firmware information"

    printf "${white}firmware information${reset}\n\n"

    printf " bios vendor       : %s\n" "$(cat /sys/class/dmi/id/bios_vendor 2>/dev/null)"
    printf " bios version      : %s\n" "$(cat /sys/class/dmi/id/bios_version 2>/dev/null)"
    printf " bios date         : %s\n" "$(cat /sys/class/dmi/id/bios_date 2>/dev/null)"
    printf " board vendor      : %s\n" "$(cat /sys/class/dmi/id/board_vendor 2>/dev/null)"
    printf " board name        : %s\n" "$(cat /sys/class/dmi/id/board_name 2>/dev/null)"
    printf " chassis vendor    : %s\n" "$(cat /sys/class/dmi/id/chassis_vendor 2>/dev/null)"
    printf " product name      : %s\n" "$(cat /sys/class/dmi/id/product_name 2>/dev/null)"

    echo

    if command -v crossystem >/dev/null 2>&1; then

        printf "${white}chromeos firmware${reset}\n\n"

        printf " firmware type     : %s\n" "$(crossystem mainfw_type 2>/dev/null)"
        printf " active slot       : %s\n" "$(crossystem mainfw_act 2>/dev/null)"
        printf " recovery reason   : %s\n" "$(crossystem recovery_reason 2>/dev/null)"

        echo
    fi
}