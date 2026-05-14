#!/bin/bash

vm_snapshot_save() {

    require_root

    name="$1"

    snapshot="$2"

    if [ -z "$snapshot" ]; then
        snapshot="default"
    fi

    vm_root="$HOME/timmy/vms"

    vm_dir="$vm_root/$name"

    if [ ! -d "$vm_dir" ]; then

        ui_fail "vm missing"

        exit 1
    fi

    ui_header

    loading "creating vm snapshot"

    qemu-img snapshot -c "$snapshot" "$vm_dir/disk.qcow2"

    ok "snapshot saved"

    log_info "snapshot $snapshot created for $name"
}

vm_snapshot_list() {

    name="$1"

    vm_root="$HOME/timmy/vms"

    vm_dir="$vm_root/$name"

    if [ ! -d "$vm_dir" ]; then

        ui_fail "vm missing"

        exit 1
    fi

    ui_header

    qemu-img snapshot -l "$vm_dir/disk.qcow2"
}