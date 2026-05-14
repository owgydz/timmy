#!/bin/bash

source "$base_dir/monitor/cpu.sh"
source "$base_dir/monitor/memory.sh"
source "$base_dir/monitor/disk.sh"
source "$base_dir/monitor/network.sh"
source "$base_dir/monitor/thermal.sh"

draw_bar() {

    percent="$1"

    bars=$((percent / 5))

    for i in $(seq 1 $bars); do
        printf "█"
    done
}

monitor_cmd() {

    log_info "monitor launched"

    while true; do

        clear

        printf "${cyan}"
        printf "╔════════════════════════════════════╗\n"
        printf "║          timmy monitor            ║\n"
        printf "╠════════════════════════════════════╣\n"
        printf "${reset}"

        monitor_cpu

        monitor_memory

        monitor_disk

        echo

        monitor_network

        monitor_thermal

        echo
        printf " session log : %s\n" "$session_log"

        sleep 2
    done
}