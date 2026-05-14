#!/bin/bash

startup_logs() {

    log_info "===================================================="
    log_info "starting timmy runtime"
    log_info "loading configuration"
    log_info "loading logging engine"
    log_info "loading command runtime"
    log_info "checking filesystem"
    log_info "checking firmware interfaces"
    log_info "checking virtualization interfaces"
    log_info "checking thermal subsystem"
    log_info "checking recovery subsystem"
    log_info "runtime initialized"
    log_info "===================================================="
}

require_root() {

    if [ "$EUID" -ne 0 ]; then
        ui_fail "root privileges required"
        exit 1
    fi
}

unsafe_check() {

    if [ ! -f "$config_dir/unsafe.conf" ]; then
        ui_fail "unsafe mode disabled"
        echo
        echo "run: timmy unsafe enable"
        echo
        exit 1
    fi
}