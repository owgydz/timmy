#!/bin/bash

set -e

repo_url="https://raw.githubusercontent.com/owgydz/timmy/main"
install_dir="/opt/timmy"
bin_dir="/usr/local/bin"

echo "[timmy] starting installer"
echo "[timmy] checking permissions"

if [ "$EUID" -ne 0 ]; then
    echo "[fail] root privileges required"
    exit 1
fi

echo "[timmy] creating directories"

mkdir -p "$install_dir"
mkdir -p "$install_dir/core"
mkdir -p "$install_dir/commands"

echo "[timmy] downloading runtime"

curl -L "$repo_url/timmy/timmy" -o "$install_dir/timmy"

chmod +x "$install_dir/timmy"

echo "[timmy] linking executable"

ln -sf "$install_dir/timmy" "$bin_dir/timmy"

echo
echo "[ ok ] timmy installed"
echo
echo "run:"
echo "timmy version"