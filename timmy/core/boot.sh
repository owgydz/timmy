#!/bin/bash

boot_menu() {

    ui_header

    log_info "boot manager launched"

    printf "${white}timmy boot manager${reset}\n\n"

    printf " 1. chromeos\n"
    printf " 2. alpine linux\n"
    printf " 3. debian recovery\n"
    printf " 4. tinycore\n"
    printf " 5. diagnostics mode\n"

    echo

    printf "${yellow}select option:${reset} "
    read choice

    case "$choice" in

        1)

            log_info "chromeos selected"

            echo "chromeos selected"
            ;;

        2)

            log_info "alpine selected"

            timmy vm start alpine
            ;;

        3)

            log_info "debian selected"

            timmy vm start debian
            ;;

        4)

            log_info "tinycore selected"

            timmy vm start tinycore
            ;;

        5)

            log_info "diagnostics selected"

            timmy monitor
            ;;

        *)

            ui_fail "invalid selection"
            ;;

    esac
}