#!/bin/bash

help_cmd() {

    ui_header

    cat << EOF

version
status
dashboard
monitor

logs
history

network scan
network ping <host>

thermal
benchmark

boot menu

vm create <name>
vm start <name>
vm list

chromeos status

recovery scan
recovery repair
recovery rebuild

unsafe enable
unsafe disable
unsafe status

firmware backup
firmware flash <image>

update <url>

help

EOF
}