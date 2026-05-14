#!/bin/bash

monitor_memory() {

    total=$(free -h | awk '/Mem:/ {print $2}')

    used=$(free -h | awk '/Mem:/ {print $3}')

    available=$(free -h | awk '/Mem:/ {print $7}')

    cached=$(free -h | awk '/Mem:/ {print $6}')

    usage=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')

    swap_total=$(free -h | awk '/Swap:/ {print $2}')

    swap_used=$(free -h | awk '/Swap:/ {print $3}')

    printf "${white}memory subsystem${reset}\n\n"

    printf " total memory   : %s\n" "$total"

    printf " used memory    : %s\n" "$used"

    printf " available      : %s\n" "$available"

    printf " cached         : %s\n" "$cached"

    printf " swap total     : %s\n" "$swap_total"

    printf " swap used      : %s\n" "$swap_used"

    printf " usage          : "

    draw_bar "$usage"

    printf " %s%%\n" "$usage"

    echo
}