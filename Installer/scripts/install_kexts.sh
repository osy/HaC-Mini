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
    elif [ $kext == "VirtualSMC.kext" -a $at -gt 0 ]; then
        # VirtualSMC has to be second, or VSMC plugins
        # will not work
        i=1
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
    base="${base/.kext/}"
    exe=`find "$line" -name "$base" -type f -maxdepth 3 | head -1`
    exe="${exe/$line\//}"
    echo "ExecutablePath: $exe"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:ExecutablePath string $exe" "$CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Add:$i:Enabled bool true" "$CONFIG"
    at=`expr $at + 1`
done
