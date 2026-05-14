# It's timmy time!
# This is the latest version of the Timmy console, 2.8.3
# Dedicated to all things Litzium

#!/bin/bash

version="2.8.3"

config_dir="/etc/timmy"
log_dir="/var/log/timmy"
log_file="$log_dir/timmy.log"

mkdir -p "$config_dir" 2>/dev/null
mkdir -p "$log_dir" 2>/dev/null

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
cyan="\e[36m"
white="\e[97m"
reset="\e[0m"

session_id=$(date +%s)

log_raw() {
    echo "$1" >> "$log_file"
}

log_info() {
    log_raw "[info][$session_id][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_warn() {
    log_raw "[warn][$session_id][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
    log_raw "[fail][$session_id][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

line() {
    printf "${blue}====================================================${reset}\n"
}

header() {
    clear
    line
    printf "${cyan} timmy engineering console v%s ${reset}\n" "$version"
    line
}

loading() {
    msg=$1

    printf "${yellow}[timmy]${reset} %s" "$msg"

    for i in {1..3}; do
        sleep 0.15
        printf "."
    done

    printf "\n"

    log_info "$msg"
}

ok() {
    printf "${green}[ ok ]${reset} %s\n" "$1"
    log_info "$1"
}

warn() {
    printf "${yellow}[warn]${reset} %s\n" "$1"
    log_warn "$1"
}

err() {
    printf "${red}[fail]${reset} %s\n" "$1"
    log_error "$1"
}

require_root() {
    if [ "$EUID" -ne 0 ]; then
        err "root privileges required"
        exit 1
    fi
}

unsafe_check() {

    if [ ! -f "$config_dir/unsafe.conf" ]; then
        err "unsafe mode disabled"
        printf "\n${yellow}run:${reset} timmy unsafe enable\n\n"
        exit 1
    fi
}

version_cmd() {
    header

    printf "${white}version information${reset}\n\n"

    printf " version       : %s\n" "$version"
    printf " hostname      : %s\n" "$(hostname)"
    printf " kernel        : %s\n" "$(uname -r)"
    printf " architecture  : %s\n" "$(uname -m)"
    printf " shell         : %s\n" "$SHELL"

    echo
}

status_cmd() {
    header

    printf "${white}system status${reset}\n\n"

    printf " hostname      : %s\n" "$(hostname)"
    printf " uptime        : %s\n" "$(uptime -p)"
    printf " kernel        : %s\n" "$(uname -r)"
    printf " memory        : %s\n" "$(free -h | awk '/Mem:/ {print $3 " / " $2}')"
    printf " load          : %s\n" "$(uptime | awk -F'load average:' '{print $2}')"
    printf " user          : %s\n" "$(whoami)"

    if [ -d /sys/class/power_supply/BAT0 ]; then
        printf " battery       : %s%%\n" "$(cat /sys/class/power_supply/BAT0/capacity)"
    fi

    echo

    log_info "status viewed"
}

dashboard_cmd() {

    log_info "dashboard started"

    while true; do

        clear

        printf "${cyan}"
        printf "╔════════════════════════════════════╗\n"
        printf "║         timmy dashboard           ║\n"
        printf "╠════════════════════════════════════╣\n"
        printf "${reset}"

        printf " hostname   : %s\n" "$(hostname)"
        printf " kernel     : %s\n" "$(uname -r)"
        printf " memory     : %s\n" "$(free -h | awk '/Mem:/ {print $3 "/" $2}')"
        printf " load       : %s\n" "$(uptime | awk -F'load average:' '{print $2}')"

        if [ -d /sys/class/power_supply/BAT0 ]; then
            printf " battery    : %s%%\n" "$(cat /sys/class/power_supply/BAT0/capacity)"
        fi

        printf "\npress ctrl+c to exit\n"

        sleep 2
    done
}

logs_cmd() {
    header
    tail -n 50 "$log_file"
}

logs_follow() {
    header
    tail -f "$log_file"
}

network_scan() {
    header

    loading "scanning network interfaces"

    ip addr

    echo

    log_info "network scan completed"
}

network_ping() {
    target="$3"

    if [ -z "$target" ]; then
        err "missing target"
        exit 1
    fi

    loading "pinging $target"

    ping -c 4 "$target"

    log_info "ping completed"
}

thermal_cmd() {
    header

    printf "${white}thermal information${reset}\n\n"

    for zone in /sys/class/thermal/thermal_zone*; do

        if [ -f "$zone/temp" ]; then

            name=$(cat "$zone/type" 2>/dev/null)
            temp=$(cat "$zone/temp")
            celsius=$((temp / 1000))

            printf " %-15s : %s°c\n" "$name" "$celsius"

        fi

    done

    echo

    log_info "thermal viewed"
}

battery_health() {
    header

    if [ ! -d /sys/class/power_supply/BAT0 ]; then
        err "battery unavailable"
        exit 1
    fi

    capacity=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)

    printf "${white}battery health${reset}\n\n"

    printf " capacity      : %s%%\n" "$capacity"
    printf " status        : %s\n" "$status"

    echo

    log_info "battery viewed"
}

cpu_governor() {
    require_root

    governor="$3"

    if [ -z "$governor" ]; then
        err "missing governor"
        exit 1
    fi

    loading "setting governor to $governor"

    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$governor" > "$cpu" 2>/dev/null
    done

    ok "governor updated"
}

processes_cmd() {
    header

    ps aux --sort=-%mem | head -20

    echo

    log_info "process list viewed"
}

disk_cmd() {
    header

    df -h

    echo

    log_info "disk usage viewed"
}

memtest_cmd() {
    header

    loading "running memory test"

    dd if=/dev/zero of=/tmp/timmy_memtest bs=1M count=512 status=none

    sync

    rm -f /tmp/timmy_memtest

    ok "memory test completed"

    log_info "memory test completed"
}

smart_cmd() {
    header

    device="$2"

    if [ -z "$device" ]; then
        device="/dev/sda"
    fi

    if ! command -v smartctl >/dev/null 2>&1; then
        err "smartctl missing"
        exit 1
    fi

    loading "running smart diagnostics"

    smartctl -H "$device"

    echo

    log_info "smart diagnostics completed"
}

shell_cmd() {
    header

    printf "${green}launching subshell...${reset}\n\n"

    log_info "subshell launched"

    bash
}

benchmark_cmd() {
    header

    loading "running benchmark"

    start=$(date +%s)

    sha256sum /dev/zero &
    pid=$!

    sleep 3

    kill $pid 2>/dev/null

    end=$(date +%s)

    printf "\nbenchmark runtime: %ss\n\n" "$((end - start))"

    log_info "benchmark completed"
}

kexec_load() {
    require_root

    kernel="$3"
    initrd="$4"

    if [ ! -f "$kernel" ]; then
        err "kernel missing"
        exit 1
    fi

    loading "loading kernel"

    if [ -n "$initrd" ]; then
        kexec -l "$kernel" --initrd="$initrd"
    else
        kexec -l "$kernel"
    fi

    ok "kernel loaded"

    log_warn "kexec kernel loaded"
}

kexec_boot() {
    require_root

    loading "executing kexec"

    log_warn "system entering kexec"

    kexec -e
}

vm_start() {
    require_root

    image="$3"

    if [ -z "$image" ]; then
        err "missing vm image"
        exit 1
    fi

    if command -v crosvm >/dev/null 2>&1; then

        loading "starting crosvm"

        crosvm run "$image"

    elif command -v qemu-system-x86_64 >/dev/null 2>&1; then

        loading "starting qemu"

        qemu-system-x86_64 -m 2048 -hda "$image"

    else
        err "no vm backend found"
    fi
}

backup_create() {
    require_root

    mkdir -p /var/backups/timmy

    timestamp=$(date +%Y%m%d_%H%M%S)

    backup="/var/backups/timmy/backup_$timestamp.tar.gz"

    loading "creating backup"

    tar -czf "$backup" /etc /home 2>/dev/null

    ok "backup created"

    printf "\n%s\n\n" "$backup"

    log_info "backup created"
}

restore_latest() {
    require_root

    backup=$(ls -t /var/backups/timmy/*.tar.gz 2>/dev/null | head -1)

    if [ -z "$backup" ]; then
        err "no backups found"
        exit 1
    fi

    loading "restoring latest backup"

    tar -xzf "$backup" -C /

    ok "backup restored"

    log_warn "system restored"
}

repair_boot() {
    require_root

    loading "repairing boot"

    if command -v update-grub >/dev/null 2>&1; then
        update-grub
    fi

    ok "boot repair completed"

    log_warn "boot repaired"
}

repair_partition() {
    require_root

    device="$3"

    if [ -z "$device" ]; then
        err "missing partition"
        exit 1
    fi

    loading "repairing partition"

    fsck -fy "$device"

    ok "partition repaired"

    log_warn "partition repaired"
}

# had to add a SAFE and UNSAFE mode after Ian bricking a thingy

unsafe_enable() {
    require_root

    clear

    printf "${red}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#                  UNSAFE MODE WARNING                     #\n"
    printf "#                                                           #\n"
    printf "#   THIS MODE CAN PERMANENTLY BRICK YOUR DEVICE.           #\n"
    printf "#   THIS CAN CORRUPT YOUR FIRMWARE OR STORAGE.             #\n"
    printf "#   USE ONLY IF YOU KNOW WHAT YOU ARE DOING.               #\n"
    printf "#                                                           #\n"
    printf "#############################################################\n"
    printf "${reset}\n\n"

    printf "${yellow}type 'i understand' to continue:${reset} "
    read confirm

    if [ "$confirm" != "i understand" ]; then
        err "unsafe mode aborted"
        exit 1
    fi

    echo "unsafe=enabled" > "$config_dir/unsafe.conf"

    ok "unsafe mode enabled"

    log_warn "unsafe mode enabled"
}

unsafe_disable() {
    require_root

    rm -f "$config_dir/unsafe.conf"

    ok "unsafe mode disabled"

    log_warn "unsafe mode disabled"
}

unsafe_status() {
    header

    if [ -f "$config_dir/unsafe.conf" ]; then
        printf "${red}unsafe mode enabled${reset}\n\n"
    else
        printf "${green}unsafe mode disabled${reset}\n\n"
    fi

    log_info "unsafe status viewed"
}

firmware_flash() {
    require_root
    unsafe_check

    image="$3"
    device="$4"

    if [ -z "$image" ] || [ -z "$device" ]; then
        err "missing image or device"
        exit 1
    fi

    clear
    
    printf "${red}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#               FIRMWARE FLASH WARNING                     #\n"
    printf "#                                                           #\n"
    printf "#   THIS CAN PERMANENTLY BRICK YOUR DEVICE.                #\n"
    printf "#                                                           #\n"
    printf "#############################################################\n"
    printf "${reset}\n\n"

    printf "${yellow}continue? (yes/no): ${reset}"
    read answer

    if [ "$answer" != "yes" ]; then
        err "firmware flash cancelled"
        exit 1
    fi

    loading "flashing firmware"

    dd if="$image" of="$device" bs=4M status=progress

    sync

    ok "firmware flash completed"

    log_warn "firmware flashed"
}

update_cmd() {
    require_root

    url="$2"

    if [ -z "$url" ]; then
        err "missing update url"
        exit 1
    fi

    tmp="/tmp/timmy_update"

    loading "downloading update"

    if command -v curl >/dev/null 2>&1; then
        curl -L "$url" -o "$tmp"
    else
        wget "$url" -O "$tmp"
    fi

    chmod +x "$tmp"

    cp "$tmp" /usr/local/bin/timmy

    ok "timmy updated"

    log_info "timmy updated"
}

help_cmd() {
    header

    cat << EOF

version
status
dashboard

logs
logs follow

network scan
network ping <host>

thermal
battery health

cpu governor performance
cpu governor powersave

processes
disk
memtest
smart /dev/sda

shell
benchmark

kexec load <kernel> [initrd]
kexec boot

vm start <disk.img>

backup create
restore latest

repair boot
repair partition <device>

unsafe enable
unsafe disable
unsafe status

firmware flash <image> <device>

update <url>

help

EOF
}

case "$1" in

    version)
        version_cmd
        ;;

    status)
        status_cmd
        ;;

    dashboard)
        dashboard_cmd
        ;;

    logs)

        case "$2" in

            follow)
                logs_follow
                ;;

            *)
                logs_cmd
                ;;

        esac
        ;;

    network)

        case "$2" in

            scan)
                network_scan
                ;;

            ping)
                network_ping "$@"
                ;;

            *)
                err "invalid network command"
                ;;

        esac
        ;;

    thermal)
        thermal_cmd
        ;;

    battery)

        case "$2" in

            health)
                battery_health
                ;;

            *)
                err "invalid battery command"
                ;;

        esac
        ;;

    cpu)

        case "$2" in

            governor)
                cpu_governor "$@"
                ;;

            *)
                err "invalid cpu command"
                ;;

        esac
        ;;

    processes)
        processes_cmd
        ;;

    disk)
        disk_cmd
        ;;

    memtest)
        memtest_cmd
        ;;

    smart)
        smart_cmd "$@"
        ;;

    shell)
        shell_cmd
        ;;

    benchmark)
        benchmark_cmd
        ;;

    kexec)

        case "$2" in

            load)
                kexec_load "$@"
                ;;

            boot)
                kexec_boot
                ;;

            *)
                err "invalid kexec command"
                ;;

        esac
        ;;

    vm)

        case "$2" in

            start)
                vm_start "$@"
                ;;

            *)
                err "invalid vm command"
                ;;

        esac
        ;;

    backup)

        case "$2" in

            create)
                backup_create
                ;;

            *)
                err "invalid backup command"
                ;;

        esac
        ;;

    restore)

        case "$2" in

            latest)
                restore_latest
                ;;

            *)
                err "invalid restore command"
                ;;

        esac
        ;;

    repair)

        case "$2" in

            boot)
                repair_boot
                ;;

            partition)
                repair_partition "$@"
                ;;

            *)
                err "invalid repair command"
                ;;

        esac
        ;;

    unsafe)

        case "$2" in

            enable)
                unsafe_enable
                ;;

            disable)
                unsafe_disable
                ;;

            status)
                unsafe_status
                ;;

            *)
                err "invalid unsafe command"
                ;;

        esac
        ;;

    firmware)

        case "$2" in

            flash)
                firmware_flash "$@"
                ;;

            *)
                err "invalid firmware command"
                ;;

        esac
        ;;

    update)
        update_cmd "$@"
        ;;

    help|"")
        help_cmd
        ;;

    *)
        err "unknown command"
        help_cmd
        ;;

esac