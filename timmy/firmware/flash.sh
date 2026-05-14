#!/bin/bash

firmware_flash() {

    require_root

    unsafe_check

    image="$1"

    if [ -z "$image" ]; then
        ui_fail "missing firmware image"
        exit 1
    fi

    if [ ! -f "$image" ]; then
        ui_fail "firmware image missing"
        exit 1
    fi

    ui_header

    printf "${red}"
    printf "Warning: Flashing firmware can permanently brick your device!!!\n"
    printf "${reset}\n\n"

    printf "${yellow}type 'flash' to continue:${reset} "

    read confirm

    if [ "$confirm" != "flash" ]; then

        ui_fail "firmware flash aborted"

        exit 1
    fi

    if ! command -v flashrom >/dev/null 2>&1; then

        ui_fail "flashrom not installed"

        exit 1
    fi

    loading "flashing firmware"

    log_warn "flashing firmware image $image"

    flashrom -p internal -w "$image"

    sync

    ok "firmware flash completed"

    log_warn "firmware flash completed"
}