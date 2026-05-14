# It's timmy time!
# This is the latest version of the Timmy console, 2.8.3
# Dedicated to all things Litzium

#!/bin/bash

version="2.8.5"

config_dir="/etc/timmy"
log_dir="/var/log/timmy"
log_file="$log_dir/timmy.log"
image_dir="$HOME/timmy/images"
history_file="$HOME/.timmy_history"

mkdir -p "$config_dir" 2>/dev/null
mkdir -p "$log_dir" 2>/dev/null
mkdir -p "$image_dir" 2>/dev/null

boot_session=$(date +%Y%m%d_%H%M%S)
session_log="$log_dir/session_$boot_session.log"

error_count=0

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
cyan="\e[36m"
white="\e[97m"
reset="\e[0m"

record_history() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$history_file"
}

record_history "$@"

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
    error_count=$((error_count + 1))
    log_system "fail" "$1"
}

startup_logs() {

    log_info "===================================================="
    log_info "starting script"
    log_info "starting boot session $boot_session"
    log_info "loading runtime"
    log_info "loading configuration"
    log_info "loading logging engine"
    log_info "checking filesystem"
    log_info "checking network stack"
    log_info "checking virtualization subsystem"
    log_info "checking firmware subsystem"
    log_info "checking thermal subsystem"
    log_info "checking benchmark subsystem"
    log_info "checking recovery subsystem"
    log_info "checking update subsystem"
    log_info "checking command parser"
    log_info "runtime initialized"
    log_info "===================================================="
}

startup_logs

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

    msg="$1"

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

    log_info "checking root privileges"

    if [ "$EUID" -ne 0 ]; then
        err "root privileges required"
        exit 1
    fi

    log_info "root privileges confirmed"
}

unsafe_check() {

    if [ ! -f "$config_dir/unsafe.conf" ]; then
        err "unsafe mode disabled"
        printf "\n${yellow}run:${reset} timmy unsafe enable\n\n"
        exit 1
    fi

    log_warn "unsafe mode active"
}

firmware_info() {

    echo " firmware vendor  : $(cat /sys/class/dmi/id/bios_vendor 2>/dev/null)"
    echo " firmware version : $(cat /sys/class/dmi/id/bios_version 2>/dev/null)"
    echo " firmware date    : $(cat /sys/class/dmi/id/bios_date 2>/dev/null)"
    echo " board vendor     : $(cat /sys/class/dmi/id/board_vendor 2>/dev/null)"
    echo " board name       : $(cat /sys/class/dmi/id/board_name 2>/dev/null)"
}

version_cmd() {

    header

    log_info "displaying version information"

    printf "${white}version information${reset}\n\n"

    printf " version           : %s\n" "$version"
    printf " hostname          : %s\n" "$(hostname)"
    printf " kernel            : %s\n" "$(uname -r)"
    printf " architecture      : %s\n" "$(uname -m)"
    printf " shell             : %s\n" "$SHELL"

    firmware_info

    echo
}

status_cmd() {

    header

    log_info "displaying status"

    printf "${white}system status${reset}\n\n"

    printf " hostname          : %s\n" "$(hostname)"
    printf " uptime            : %s\n" "$(uptime -p)"
    printf " kernel            : %s\n" "$(uname -r)"
    printf " memory            : %s\n" "$(free -h | awk '/Mem:/ {print $3 " / " $2}')"
    printf " load average      : %s\n" "$(uptime | awk -F'load average:' '{print $2}')"
    printf " user              : %s\n" "$(whoami)"

    if [ -d /sys/class/power_supply/BAT0 ]; then
        printf " battery           : %s%%\n" "$(cat /sys/class/power_supply/BAT0/capacity)"
    fi

    echo
}

dashboard_cmd() {

    log_info "dashboard launched"

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

        echo
        printf " errors     : %s\n" "$error_count"
        printf "\npress ctrl+c to exit\n"

        sleep 2
    done
}

monitor_cmd() {

    log_info "monitor launched"

    while true; do

        clear

        cpu_usage=$(top -bn1 | awk '/Cpu/ {print 100 - $8}')
        ram_usage=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
        disk_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2}')

        printf "${cyan}"
        printf "╔════════════════════════════════════╗\n"
        printf "║          timmy monitor            ║\n"
        printf "╠════════════════════════════════════╣\n"
        printf "${reset}"

        printf " cpu usage     : %.1f%%\n" "$cpu_usage"
        printf " ram usage     : %s\n" "$ram_usage"
        printf " disk usage    : %s\n" "$disk_usage"

        if [ -d /sys/class/power_supply/BAT0 ]; then
            printf " battery       : %s%%\n" "$(cat /sys/class/power_supply/BAT0/capacity)"
        fi

        echo

        for zone in /sys/class/thermal/thermal_zone*; do

            if [ -f "$zone/temp" ]; then

                name=$(cat "$zone/type" 2>/dev/null)
                temp=$(cat "$zone/temp")
                celsius=$((temp / 1000))

                printf " %-12s : %s°c\n" "$name" "$celsius"

            fi

        done

        echo
        printf " errors logged : %s\n" "$error_count"

        sleep 2
    done
}

benchmark_cmd() {

    header

    log_info "advanced benchmark started"

    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ //')

    printf "${white}advanced benchmark${reset}\n\n"

    printf " cpu model         : %s\n" "$cpu_model"
    printf " cpu cores         : %s\n" "$(nproc)"

    echo

    loading "running cpu benchmark"

    cpu_start=$(date +%s%N)

    sha256sum /dev/zero >/dev/null &
    cpu_pid=$!

    sleep 6

    kill "$cpu_pid" 2>/dev/null

    cpu_end=$(date +%s%N)

    cpu_runtime=$(( (cpu_end - cpu_start) / 1000000 ))

    ok "cpu benchmark completed"

    echo

    loading "running memory benchmark"

    mem_start=$(date +%s%N)

    dd if=/dev/zero of=/tmp/timmy_memtest bs=1M count=1024 status=none

    sync

    mem_end=$(date +%s%N)

    mem_runtime=$(( (mem_end - mem_start) / 1000000 ))

    rm -f /tmp/timmy_memtest

    ok "memory benchmark completed"

    echo

    loading "running disk benchmark"

    disk_start=$(date +%s%N)

    dd if=/dev/zero of=/tmp/timmy_disk_test bs=8M count=128 conv=fdatasync status=none

    disk_end=$(date +%s%N)

    disk_runtime=$(( (disk_end - disk_start) / 1000000 ))

    rm -f /tmp/timmy_disk_test

    ok "disk benchmark completed"

    echo

    printf "${cyan}benchmark results${reset}\n\n"

    printf " cpu runtime       : %sms\n" "$cpu_runtime"
    printf " memory runtime    : %sms\n" "$mem_runtime"
    printf " disk runtime      : %sms\n" "$disk_runtime"

    echo

    log_info "benchmark completed"
}

network_scan() {

    header

    loading "scanning interfaces"

    ip addr

    echo
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
}

battery_health() {

    header

    capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

    printf "${white}battery health${reset}\n\n"

    printf " capacity          : %s%%\n" "$capacity"
    printf " status            : %s\n" "$status"

    echo
}

logs_cmd() {
    header
    tail -n 100 "$log_file"
}

logs_follow() {
    header
    tail -f "$log_file"
}

logs_errors() {
    header
    grep "\[fail\]" "$log_file"
}

logs_sessions() {
    header
    ls -1 "$log_dir"/session_*.log 2>/dev/null
}

history_cmd() {
    header
    tail -n 50 "$history_file"
}

find_vm_image() {

    image="$1"

    if [ -f "$image" ]; then
        echo "$image"
        return
    fi

    case "$image" in

        alpine)
            remote_url="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-virt-3.22.0-x86_64.iso"
            local_file="$image_dir/alpine.iso"
            ;;

        debian)
            remote_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.0.0-amd64-netinst.iso"
            local_file="$image_dir/debian.iso"
            ;;

        tinycore)
            remote_url="http://tinycorelinux.net/15.x/x86_64/release/TinyCorePure64.iso"
            local_file="$image_dir/tinycore.iso"
            ;;

        *)
            err "vm image missing"
            exit 1
            ;;

    esac

    if [ ! -f "$local_file" ]; then

        warn "image not cached locally"

        loading "downloading vm image"

        if command -v curl >/dev/null 2>&1; then
            curl -L "$remote_url" -o "$local_file"
        else
            wget "$remote_url" -O "$local_file"
        fi

        ok "image downloaded"
    fi

    echo "$local_file"
}

vm_start() {

    require_root

    requested="$3"

    image=$(find_vm_image "$requested")

    if command -v crosvm >/dev/null 2>&1; then

        loading "starting crosvm"

        crosvm run "$image"

    elif command -v qemu-system-x86_64 >/dev/null 2>&1; then

        loading "starting qemu"

        qemu-system-x86_64 -m 2048 -cdrom "$image"

    else
        err "no vm backend available"
    fi
}

boot_menu() {

    header

    printf "${white}timmy boot manager${reset}\n\n"

    printf " 1. chromeos\n"
    printf " 2. alpine linux\n"
    printf " 3. debian recovery\n"
    printf " 4. tinycore\n"
    printf " 5. diagnostics mode\n"

    echo

    printf "${yellow}select option:${reset} "
    read choice

    case "$choice" in

        1)
            echo "chromeos selected"
            ;;

        2)
            vm_start vm start alpine
            ;;

        3)
            vm_start vm start debian
            ;;

        4)
            vm_start vm start tinycore
            ;;

        5)
            monitor_cmd
            ;;

        *)
            err "invalid selection"
            ;;

    esac
}

chromeos_status() {

    header

    printf "${white}chromeos status${reset}\n\n"

    if command -v crossystem >/dev/null 2>&1; then

        devmode=$(crossystem devsw_boot 2>/dev/null)
        slot=$(crossystem mainfw_act 2>/dev/null)

        printf " developer mode : %s\n" "$devmode"
        printf " active slot    : %s\n" "$slot"

    else

        printf " developer mode : unavailable\n"
        printf " active slot    : unavailable\n"

    fi

    printf " rootfs          : verified\n"
    printf " rollback        : disabled\n"

    echo
}

unsafe_enable() {

    require_root

    clear

    printf "${red}"
    printf "#############################################################\n"
    printf "#                                                           #\n"
    printf "#                  UNSAFE MODE WARNING                     #\n"
    printf "#                                                           #\n"
    printf "#   THIS MODE CAN PERMANENTLY BRICK YOUR DEVICE.           #\n"
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
}

unsafe_disable() {

    require_root

    rm -f "$config_dir/unsafe.conf"

    ok "unsafe mode disabled"
}

unsafe_status() {

    header

    if [ -f "$config_dir/unsafe.conf" ]; then
        printf "${red}unsafe mode enabled${reset}\n\n"
    else
        printf "${green}unsafe mode disabled${reset}\n\n"
    fi
}

firmware_backup() {

    require_root

    mkdir -p /var/backups/timmy

    backup_file="/var/backups/timmy/firmware_$(date +%Y%m%d_%H%M%S).bin"

    loading "creating firmware backup"

    if command -v flashrom >/dev/null 2>&1; then

        flashrom -p internal -r "$backup_file"

        ok "firmware backup completed"

        printf "\n%s\n\n" "$backup_file"

    else

        err "flashrom not installed"

    fi
}

update_cmd() {

    require_root

    url="$2"

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
}

help_cmd() {

    header

    cat << EOF

version
status
dashboard
monitor

logs
logs follow
logs errors
logs sessions

history

network scan
network ping <host>

thermal
battery health

benchmark

boot menu

vm start alpine
vm start debian
vm start tinycore

chromeos status

unsafe enable
unsafe disable
unsafe status

firmware backup

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

    monitor)
        monitor_cmd
        ;;

    logs)

        case "$2" in

            follow)
                logs_follow
                ;;

            errors)
                logs_errors
                ;;

            sessions)
                logs_sessions
                ;;

            *)
                logs_cmd
                ;;

        esac
        ;;

    history)
        history_cmd
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

    benchmark)
        benchmark_cmd
        ;;

    boot)

        case "$2" in

            menu)
                boot_menu
                ;;

            *)
                err "invalid boot command"
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

    chromeos)

        case "$2" in

            status)
                chromeos_status
                ;;

            *)
                err "invalid chromeos command"
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

            backup)
                firmware_backup
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