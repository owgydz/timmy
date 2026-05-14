#!/bin/bash

monitor_network() {

    default_if=$(ip route | awk '/default/ {print $5}' | head -1)

    local_ip=$(ip addr show "$default_if" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -1)

    gateway=$(ip route | awk '/default/ {print $3}' | head -1)

    rx=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')

    tx=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}')

    rx_mb=$((rx / 1024 / 1024))

    tx_mb=$((tx / 1024 / 1024))

    printf "${white}network subsystem${reset}\n\n"

    printf " interface      : %s\n" "$default_if"

    printf " local ip       : %s\n" "$local_ip"

    printf " gateway        : %s\n" "$gateway"

    printf " received       : %s mb\n" "$rx_mb"

    printf " transmitted    : %s mb\n" "$tx_mb"

    echo
}