#!/bin/sh

set -e

CONFIG="$1"
ACPIDIR="$2"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

$PLIST_BUDDY -c "Delete :ACPI:Add" "$CONFIG" || true
$PLIST_BUDDY -c "Add :ACPI:Add array" "$CONFIG"

find "$ACPIDIR" -name '*.aml' -type f -depth 1 | \
while read line
do
    $PLIST_BUDDY -c "Add :ACPI:Add:0 dict" "$CONFIG"
    acpi="${line/$ACPIDIR\//}"
    echo "Found $acpi"
    $PLIST_BUDDY -c "Add :ACPI:Add:0:Path string $acpi" "$CONFIG"
    $PLIST_BUDDY -c "Add :ACPI:Add:0:Enabled bool true" "$CONFIG"
done
