#!/bin/bash

set -e

echo "[timmy iso] starting live environment build"

work_dir="/tmp/timmy-live"
iso_dir="$work_dir/iso"

rm -rf "$work_dir"

mkdir -p "$iso_dir"

echo "[timmy iso] copying runtime"

cp -r ../timmy "$iso_dir/"

echo "[timmy iso] generating boot structure"

mkdir -p "$iso_dir/boot"

cat > "$iso_dir/boot/start.sh" << EOF
#!/bin/bash
clear
echo "timmy live environment"
bash
EOF

chmod +x "$iso_dir/boot/start.sh"

echo "[timmy iso] creating archive"

tar -czf ../timmy-live.tar.gz -C "$iso_dir" .

echo
echo "[ ok ] live environment generated"
echo
echo "../timmy-live.tar.gz"