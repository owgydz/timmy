#!/bin/bash

firmware_backup() {

    require_root

    backup_dir="/var/backups/timmy"

    mkdir -p "$backup_dir"

    backup_file="$backup_dir/firmware_$(date +%Y%m%d_%H%M%S).bin"

    ui_header

    log_warn "starting firmware backup"

    printf "${yellow}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#                 FIRMWARE BACKUP MODE                     #\n"
    printf "#                                                           #\n"
    printf "#############################################################\n"
    printf "${reset}\n\n"

    if ! command -v flashrom >/dev/null 2>&1; then

        ui_fail "flashrom not installed"

        exit 1
    fi

    loading "reading firmware image"

    flashrom -p internal -r "$backup_file"

    sync

    ok "firmware backup completed"

    echo
    echo "$backup_file"
    echo

    log_warn "firmware backup saved to $backup_file"
}