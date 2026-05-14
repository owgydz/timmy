#!/bin/bash

benchmark_cmd() {

    ui_header

    log_info "benchmark started"

    printf "${white}advanced benchmark${reset}\n\n"

    printf " cpu model         : %s\n" "$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2)"

    echo

    loading "running cpu benchmark"

    start=$(date +%s%N)

    sha256sum /dev/zero >/dev/null &
    pid=$!

    sleep 5

    kill "$pid" 2>/dev/null

    end=$(date +%s%N)

    runtime=$(( (end - start) / 1000000 ))

    ok "benchmark completed"

    echo

    printf " runtime           : %sms\n" "$runtime"

    echo
}