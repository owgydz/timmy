#!/bin/bash

chromeos_status() {

    ui_header

    printf "${white}chromeos status${reset}\n\n"

    if command -v crossystem >/dev/null 2>&1; then

        printf " developer mode : %s\n" "$(crossystem devsw_boot 2>/dev/null)"
        printf " active slot    : %s\n" "$(crossystem mainfw_act 2>/dev/null)"

    else

        printf " developer mode : unavailable\n"
        printf " active slot    : unavailable\n"

    fi

    echo
}