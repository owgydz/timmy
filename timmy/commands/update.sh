#!/bin/bash

update_cmd() {

    require_root

    url="$1"

    if [ -z "$url" ]; then
        ui_fail "missing update url"
        exit 1
    fi

    tmp="/tmp/timmy_update"

    loading "downloading update"

    curl -L "$url" -o "$tmp"

    chmod +x "$tmp"

    cp "$tmp" /usr/local/bin/timmy

    ok "timmy updated"
}