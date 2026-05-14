#!/bin/bash

source "$base_dir/reco/scan.sh"
source "$base_dir/reco/repair.sh"
source "$base_dir/reco/rebuild.sh"

recovery_cmd() {

    case "$1" in

        scan)

            recovery_scan
            ;;

        repair)

            recovery_repair
            ;;

        rebuild)

            recovery_rebuild
            ;;

        *)

            ui_fail "invalid recovery command"
            ;;

    esac
}