#!/bin/bash

monitor_cpu() {

    usage=$(top -bn1 | awk '/Cpu/ {print int(100 - $8)}')

    load=$(uptime | awk -F'load average:' '{print $2}')

    model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ //')

    cores=$(nproc)

    governor="unknown"

    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    fi

    freq="unknown"

    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
        freq_raw=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
        freq="$((freq_raw / 1000)) mhz"
    fi

    printf "${white}cpu subsystem${reset}\n\n"

    printf " model          : %s\n" "$model"

    printf " cores          : %s\n" "$cores"

    printf " governor       : %s\n" "$governor"

    printf " frequency      : %s\n" "$freq"

    printf " load average   : %s\n" "$load"

    printf " usage          : "

    draw_bar "$usage"

    printf " %s%%\n" "$usage"

    echo
}