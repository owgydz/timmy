#!/bin/bash

network_scan() {

    ui_header

    loading "scanning interfaces"

    ip addr

    echo
}

network_ping() {

    target="$1"

    if [ -z "$target" ]; then
        ui_fail "missing target"
        exit 1
    fi

    loading "pinging $target"

    ping -c 4 "$target"
}