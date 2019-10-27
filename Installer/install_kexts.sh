#!/bin/sh

set -e

CONFIG="$1"
KEXTDIR="$2"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

$PLIST_BUDDY -c "Delete :Kernel:Add" "$CONFIG" || true
$PLIST_BUDDY -c "Add :Kernel:Add array" "$CONFIG"

find "$KEXTDIR" -name '*.kext' -type d | \
while read line
do
    echo "Found $line"
    $PLIST_BUDDY -c "Add :Kernel:Add:0 dict" "$CONFIG"
    kext="${line/$KEXTDIR\//}"
    echo "BundlePath:     $kext"
    $PLIST_BUDDY -c "Add :Kernel:Add:0:BundlePath string $kext" "$CONFIG"
    info=`find "$line" -name 'Info.plist' -type f -maxdepth 2 | head -1`
    info="${info/$line\//}"
    echo "PlistPath:      $info"
    $PLIST_BUDDY -c "Add :Kernel:Add:0:PlistPath string $info" "$CONFIG"
    base=`basename $kext`
    base="${base/.kext/}"
    exe=`find "$line" -name "$base" -type f -maxdepth 3 | head -1`
    exe="${exe/$line\//}"
    echo "ExecutablePath: $exe"
    $PLIST_BUDDY -c "Add :Kernel:Add:0:ExecutablePath string $exe" "$CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Add:0:Enabled bool true" "$CONFIG"
done
