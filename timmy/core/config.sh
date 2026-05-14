#!/bin/bash

version="3.0"

config_dir="/etc/timmy"
image_dir="$HOME/timmy/images"
history_file="$HOME/.timmy_history"

mkdir -p "$config_dir" 2>/dev/null
mkdir -p "$image_dir" 2>/dev/null

theme="chromeos"