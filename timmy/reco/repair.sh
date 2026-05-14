#!/bin/bash

recovery_repair() {

    require_root

    ui_header

    log_warn "starting automated recovery repair"

    printf "${yellow}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#                 RECOVERY REPAIR MODE                     #\n"
    printf "#                                                           #\n"
    printf "#############################################################\n"
    printf "${reset}\n\n"

    loading "repairing filesystem"

    fsck -fy /

    echo

    loading "rebuilding bootloader"

    if command -v update-grub >/dev/null 2>&1; then

        update-grub

    fi

    echo

    loading "reloading filesystem metadata"

    sync

    ok "recovery repair completed"

    log_warn "recovery repair completed"
}