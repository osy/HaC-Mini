#!/bin/sh

set -e

CONFIG="$1"
KEXTDIR="$2"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

$PLIST_BUDDY -c "Delete :Kernel:Add" "$CONFIG" || true
$PLIST_BUDDY -c "Add :Kernel:Add array" "$CONFIG"

i=0
find "$KEXTDIR" -name '*.kext' -type d | \
while read line
do
    _pf="$line.Priority.txt"
    _priority=9999
    if [ -f "$_pf" ]; then
        _priority=`cat "$_pf"`
        rm "$_pf"
    fi
    echo "$_priority $line"
done | sort | \
while read line
do
    priority=`echo $line | awk '{ print $1 }'`
    file=`echo $line | awk '{$1=""; print substr($0,2)}'`
    echo "Found $file (priority $priority)"
    kext="${file/$KEXTDIR\//}"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i dict" "$CONFIG"
    echo "BundlePath:     $kext"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:BundlePath string $kext" "$CONFIG"
    info=`find "$file" -name 'Info.plist' -type f -maxdepth 2 | head -1`
    info="${info/$file\//}"
    echo "PlistPath:      $info"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:PlistPath string $info" "$CONFIG"
    base=`basename $kext`
    # Find MaxKernel config
    maxKernel=`cat "$KEXTDIR/$base.MaxKernel.txt" 2> /dev/null || true`
    if [ ! -z "$maxKernel" ]; then
        echo "MaxKernel:      $maxKernel"
        $PLIST_BUDDY -c "Add :Kernel:Add:$i:MaxKernel string $maxKernel" "$CONFIG"
        rm "$KEXTDIR/$base.MaxKernel.txt" # no longer needed
    fi
    # Find MinKernel config
    minKernel=`cat "$KEXTDIR/$base.MinKernel.txt" 2> /dev/null || true`
    if [ ! -z "$minKernel" ]; then
        echo "MinKernel:      $minKernel"
        $PLIST_BUDDY -c "Add :Kernel:Add:$i:MinKernel string $minKernel" "$CONFIG"
        rm "$KEXTDIR/$base.MinKernel.txt" # no longer needed
    fi
    exe=`find "$file" -path "*/Contents/MacOS/*" -type f -maxdepth 3 | head -1`
    exe="${exe/$file\//}"
    echo "ExecutablePath: $exe"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:ExecutablePath string $exe" "$CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:Enabled bool true" "$CONFIG"
    i=`expr $i + 1`
done
