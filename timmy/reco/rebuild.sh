#!/bin/bash

recovery_rebuild() {

    require_root

    ui_header

    log_warn "starting recovery rebuild"

    printf "${red}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#                 RECOVERY REBUILD MODE                    #\n"
    printf "#                                                           #\n"
    printf "#   THIS MAY MODIFY BOOT CONFIGURATIONS.                   #\n"
    printf "#                                                           #\n"
    printf "#############################################################\n"
    printf "${reset}\n\n"

    printf "${yellow}type 'rebuild to continue:${reset} "

    read confirm

    if [ "$confirm" != "rebuild" ]; then

        ui_fail "rebuild aborted"

        exit 1
    fi

    loading "rebuilding initramfs"

    if command -v dracut >/dev/null 2>&1; then

        dracut --force

    elif command -v update-initramfs >/dev/null 2>&1; then

        update-initramfs -u

    fi

    echo

    loading "rebuilding boot configuration"

    if command -v update-grub >/dev/null 2>&1; then

        update-grub

    fi

    echo

    loading "synchronizing filesystem"

    sync

    ok "recovery rebuild completed"

    log_warn "recovery rebuild completed"
}