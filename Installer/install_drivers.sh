#!/bin/sh

set -e

CONFIG="$1"
DRIVERSDIR="$2"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

$PLIST_BUDDY -c "Delete :UEFI:Drivers" "$CONFIG" || true
$PLIST_BUDDY -c "Add :UEFI:Drivers array" "$CONFIG"

find "$DRIVERSDIR" -name '*.efi' -type f -depth 1 | \
while read line
do
    driver="${line/$DRIVERSDIR\//}"
    echo "Found $driver"
    $PLIST_BUDDY -c "Add :UEFI:Drivers:0 string $driver" "$CONFIG"
done
