#!/bin/bash

set -e

echo "[timmy release] preparing release"

version=$(grep 'version=' ../timmy/timmy | head -1 | cut -d'"' -f2)

echo "[timmy release] detected version $version"

mkdir -p ../release

tar -czf "../release/timmy-$version.tar.gz" ../timmy

echo
echo "[ ok ] release generated"
echo
echo "../release/timmy-$version.tar.gz"