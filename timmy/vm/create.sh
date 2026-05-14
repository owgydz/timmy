#!/bin/bash

vm_create() {

    require_root

    name="$1"

    if [ -z "$name" ]; then
        ui_fail "missing vm name"
        exit 1
    fi

    vm_root="$HOME/timmy/vms"

    vm_dir="$vm_root/$name"

    mkdir -p "$vm_dir"

    ui_header

    log_info "creating vm $name"

    loading "creating virtual disk"

    qemu-img create -f qcow2 "$vm_dir/disk.qcow2" 20G

    cat > "$vm_dir/config.conf" << EOF
memory=2048
cpus=2
network=nat
EOF

    ok "vm created"

    echo
    echo "$vm_dir"
    echo
}