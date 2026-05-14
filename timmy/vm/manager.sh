#!/bin/bash

vm_list() {

    ui_header

    vm_root="$HOME/timmy/vms"

    printf "${white}registered virtual machines${reset}\n\n"

    ls "$vm_root" 2>/dev/null

    echo
}

vm_delete() {

    require_root

    name="$1"

    vm_root="$HOME/timmy/vms"

    vm_dir="$vm_root/$name"

    if [ ! -d "$vm_dir" ]; then

        ui_fail "vm missing"

        exit 1
    fi

    ui_header

    printf "${red}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#                  VM DELETION WARNING                     #\n"
    printf "#                                                           #\n"
    printf "#   THIS WILL PERMANENTLY DELETE THE VM.                   #\n"
    printf "#                                                           #\n"
    printf "#############################################################\n"
    printf "${reset}\n\n"

    printf "${yellow}type 'delete vm' to continue:${reset} "

    read confirm

    if [ "$confirm" != "delete vm" ]; then

        ui_fail "vm deletion aborted"

        exit 1
    fi

    rm -rf "$vm_dir"

    ok "vm deleted"
}