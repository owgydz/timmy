#!/bin/bash

version_cmd() {

    ui_header

    log_info "displaying version information"

    printf "${white}version information${reset}\n\n"

    printf " version           : %s\n" "$version"
    printf " hostname          : %s\n" "$(hostname)"
    printf " kernel            : %s\n" "$(uname -r)"
    printf " architecture      : %s\n" "$(uname -m)"
    printf " shell             : %s\n" "$SHELL"

    echo
}