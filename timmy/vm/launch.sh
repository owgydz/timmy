#!/bin/bash

vm_start() {

    require_root

    name="$1"

    vm_root="$HOME/timmy/vms"

    vm_dir="$vm_root/$name"

    if [ ! -d "$vm_dir" ]; then

        ui_fail "vm missing"

        exit 1
    fi

    source "$vm_dir/config.conf"

    ui_header

    log_info "starting vm $name"

    printf "${white}virtual machine information${reset}\n\n"

    printf " vm name         : %s\n" "$name"
    printf " memory          : %s mb\n" "$memory"
    printf " cpus            : %s\n" "$cpus"
    printf " network         : %s\n" "$network"

    echo

    loading "launching qemu virtual machine"

    qemu-system-x86_64 \
        -m "$memory" \
        -smp "$cpus" \
        -hda "$vm_dir/disk.qcow2"
}