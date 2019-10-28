#!/bin/sh

set -e

CONFIG="$1"
KEXTDIR="$2"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

$PLIST_BUDDY -c "Delete :Kernel:Add" "$CONFIG" || true
$PLIST_BUDDY -c "Add :Kernel:Add array" "$CONFIG"

at=0
find "$KEXTDIR" -name '*.kext' -type d | \
while read line
do
    echo "Found $line"
    kext="${line/$KEXTDIR\//}"
    if [ $kext == "Lilu.kext" ]; then
        # we need Lilu to be first on the list
        # or the computer can't boot
        i=0
    else
        i=$at
    fi
    $PLIST_BUDDY -c "Add :Kernel:Add:$i dict" "$CONFIG"
    echo "BundlePath:     $kext"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:BundlePath string $kext" "$CONFIG"
    info=`find "$line" -name 'Info.plist' -type f -maxdepth 2 | head -1`
    info="${info/$line\//}"
    echo "PlistPath:      $info"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:PlistPath string $info" "$CONFIG"
    base=`basename $kext`
    base="${base/.kext/}"
    exe=`find "$line" -name "$base" -type f -maxdepth 3 | head -1`
    exe="${exe/$line\//}"
    echo "ExecutablePath: $exe"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:ExecutablePath string $exe" "$CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:Enabled bool true" "$CONFIG"
    at=`expr $at + 1`
done
