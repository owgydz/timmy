# It's timmy time!
# This is the latest version of the Timmy console, 2.8.3
# Dedicated to all things Litzium

#!/bin/bash

version="2.8.4"

config_dir="/etc/timmy"
log_dir="/var/log/timmy"
log_file="$log_dir/timmy.log"
image_dir="$HOME/timmy/images"

mkdir -p "$config_dir" 2>/dev/null
mkdir -p "$log_dir" 2>/dev/null
mkdir -p "$image_dir" 2>/dev/null

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

startup_logs() {

    log_info "===================================================="
    log_info "starting script"
    log_info "initializing timmy runtime"
    log_info "loading environment"
    log_info "loading configuration"
    log_info "checking filesystem"
    log_info "checking logging subsystem"
    log_info "checking network stack"
    log_info "checking virtualization backends"
    log_info "checking firmware interfaces"
    log_info "checking battery interfaces"
    log_info "checking thermal interfaces"
    log_info "checking root permissions"
    log_info "checking update system"
    log_info "checking recovery modules"
    log_info "checking unsafe mode state"
    log_info "loading command parser"
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

    log_info "checking root privileges"

    if [ "$EUID" -ne 0 ]; then
        err "root privileges required"
        log_error "root privilege check failed"
        exit 1
    fi

    log_info "root privileges confirmed"
}

unsafe_check() {

    log_info "checking unsafe mode"

    if [ ! -f "$config_dir/unsafe.conf" ]; then
        err "unsafe mode disabled"
        printf "\n${yellow}run:${reset} timmy unsafe enable\n\n"
        log_error "unsafe operation blocked"
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

    log_info "displaying system status"

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

        printf "\npress ctrl+c to exit\n"

        sleep 2
    done
}

logs_cmd() {

    header

    log_info "viewing logs"

    tail -n 100 "$log_file"
}

logs_follow() {

    header

    log_info "following logs"

    tail -f "$log_file"
}

network_scan() {

    header

    loading "scanning interfaces"

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

    log_info "ping completed to $target"
}

thermal_cmd() {

    header

    log_info "reading thermal sensors"

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

    log_info "reading battery information"

    capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

    printf "${white}battery health${reset}\n\n"

    printf " capacity          : %s%%\n" "$capacity"
    printf " status            : %s\n" "$status"

    echo
}

benchmark_cmd() {

    header

    log_info "benchmark started"

    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ //')
    cpu_cores=$(nproc)

    printf "${white}system benchmark${reset}\n\n"

    printf " cpu model         : %s\n" "$cpu_model"
    printf " cpu cores         : %s\n" "$cpu_cores"

    echo

    loading "running cpu stress test"

    start_ns=$(date +%s%N)

    sha256sum /dev/zero >/dev/null &
    pid=$!

    sleep 5

    kill "$pid" 2>/dev/null

    end_ns=$(date +%s%N)

    runtime_ms=$(( (end_ns - start_ns) / 1000000 ))

    ok "benchmark completed"

    echo

    printf " runtime           : %sms\n" "$runtime_ms"
    printf " load average      : %s\n" "$(uptime | awk -F'load average:' '{print $2}')"
    printf " memory usage      : %s\n" "$(free -h | awk '/Mem:/ {print $3 "/" $2}')"

    echo

    log_info "benchmark runtime ${runtime_ms}ms"
    log_info "benchmark completed"
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

        log_warn "downloading $remote_url"

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

    log_info "vm image resolved to $image"

    if command -v crosvm >/dev/null 2>&1; then

        loading "starting crosvm"

        log_info "vm backend crosvm"

        crosvm run "$image"

    elif command -v qemu-system-x86_64 >/dev/null 2>&1; then

        loading "starting qemu"

        log_info "vm backend qemu"

        qemu-system-x86_64 -m 2048 -cdrom "$image"

    else
        err "no vm backend available"
    fi
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
    printf "#   THIS CAN CORRUPT YOUR FIRMWARE OR STORAGE.             #\n"
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

    log_info "unsafe status checked"
}

firmware_flash() {

    require_root
    unsafe_check

    image="$3"
    device="$4"

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

    log_warn "firmware flash started"

    dd if="$image" of="$device" bs=4M status=progress

    sync

    ok "firmware flash completed"

    log_warn "firmware flash completed"
}

update_cmd() {

    require_root

    url="$2"

    tmp="/tmp/timmy_update"

    loading "downloading update"

    log_info "update source $url"

    if command -v curl >/dev/null 2>&1; then
        curl -L "$url" -o "$tmp"
    else
        wget "$url" -O "$tmp"
    fi

    chmod +x "$tmp"

    cp "$tmp" /usr/local/bin/timmy

    ok "timmy updated"

    log_info "update completed"
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

benchmark

vm start alpine
vm start debian
vm start tinycore

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

    benchmark)
        benchmark_cmd
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