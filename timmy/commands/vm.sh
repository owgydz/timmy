#!/bin/bash

vm_root="$HOME/timmy/vms"

mkdir -p "$vm_root" 2>/dev/null

vm_create() {

    name="$1"

    if [ -z "$name" ]; then
        ui_fail "missing vm name"
        exit 1
    fi

    vm_dir="$vm_root/$name"

    mkdir -p "$vm_dir"

    qemu-img create -f qcow2 "$vm_dir/disk.qcow2" 20G

    cat > "$vm_dir/config.conf" << EOF
memory=2048
cpus=2
EOF

    ok "vm created"
}

vm_start() {

    name="$1"

    vm_dir="$vm_root/$name"

    if [ ! -d "$vm_dir" ]; then
        ui_fail "vm missing"
        exit 1
    fi

    qemu-system-x86_64 \
        -m 2048 \
        -hda "$vm_dir/disk.qcow2"
}

vm_list() {

    ui_header

    ls "$vm_root"
}