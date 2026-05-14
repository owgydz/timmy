#!/bin/bash

log_dir="/var/log/timmy"
log_file="$log_dir/timmy.log"

mkdir -p "$log_dir" 2>/dev/null

boot_session=$(date +%Y%m%d_%H%M%S)
session_log="$log_dir/session_$boot_session.log"

log_system() {

    subsystem="$1"
    message="$2"

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp][$subsystem] $message" >> "$log_file"
    echo "[$timestamp][$subsystem] $message" >> "$session_log"
}

log_info() {
    log_system "info" "$1"
}

log_warn() {
    log_system "warn" "$1"
}

log_error() {
    log_system "fail" "$1"
}