#!/bin/bash

record_history() {

    mkdir -p "$(dirname "$history_file")" 2>/dev/null

    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$history_file"
}

show_history() {

    tail -n 50 "$history_file" 2>/dev/null
}