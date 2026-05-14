#!/bin/bash

monitor_disk() {

    usage=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

    total=$(df -h / | awk 'NR==2 {print $2}')

    used=$(df -h / | awk 'NR==2 {print $3}')

    available=$(df -h / | awk 'NR==2 {print $4}')

    filesystem=$(df -T / | awk 'NR==2 {print $2}')

    read_speed=$(dd if=/dev/zero of=/tmp/timmy_disk_speed bs=4M count=32 conv=fdatasync 2>&1 | awk '/copied/ {print $(NF-1),$NF}')

    rm -f /tmp/timmy_disk_speed

    printf "${white}disk subsystem${reset}\n\n"

    printf " filesystem     : %s\n" "$filesystem"

    printf " total space    : %s\n" "$total"

    printf " used space     : %s\n" "$used"

    printf " available      : %s\n" "$available"

    printf " write speed    : %s\n" "$read_speed"

    printf " usage          : "

    draw_bar "$usage"

    printf " %s%%\n" "$usage"

    echo
}