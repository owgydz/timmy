#!/bin/bash

set -e

echo "[timmy build] starting"

root_dir="$(cd "$(dirname "$0")/.." && pwd)"

output_dir="$root_dir/build"

mkdir -p "$output_dir"

echo "[timmy build] copying runtime"

cp -r "$root_dir/timmy" "$output_dir/"

echo "[timmy build] packaging release"

tar -czf "$output_dir/timmy-v3.0.tar.gz" -C "$output_dir" timmy

echo
echo "[ ok ] build completed"
echo
echo "$output_dir/timmy-v3.0.tar.gz"