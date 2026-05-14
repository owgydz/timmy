#!/bin/bash

recovery_scan() {

    ui_header

    log_warn "starting recovery scan"

    printf "${white}recovery scan${reset}\n\n"

    printf " checking mounted filesystems...\n"

    mounts=$(mount | wc -l)

    printf " mounted filesystems : %s\n\n" "$mounts"

    printf " checking root filesystem...\n"

    root_usage=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

    printf " root usage          : %s%%\n" "$root_usage"

    if [ "$root_usage" -ge 95 ]; then
        printf "${red} rootfs status       : critical${reset}\n"
    elif [ "$root_usage" -ge 80 ]; then
        printf "${yellow} rootfs status       : warning${reset}\n"
    else
        printf "${green} rootfs status       : healthy${reset}\n"
    fi

    echo

    printf " checking boot files...\n"

    if [ -f /boot/vmlinuz-linux ] || [ -d /boot ]; then
        printf "${green} boot files detected${reset}\n"
    else
        printf "${red} boot files missing${reset}\n"
    fi

    echo

    printf " checking partition table...\n"

    lsblk

    echo

    printf " checking failed systemd units...\n\n"

    if command -v systemctl >/dev/null 2>&1; then

        failed=$(systemctl --failed --no-legend 2>/dev/null | wc -l)

        printf " failed units        : %s\n" "$failed"

    else

        printf " systemd unavailable\n"

    fi

    echo

    log_warn "recovery scan completed"
}