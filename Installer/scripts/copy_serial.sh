#!/bin/sh

set -e
if [ $# -lt 2 ]; then
    echo "usage: $0 existing.plist new.plist"
    exit 1
fi

PLIST_BUDDY="/usr/libexec/PlistBuddy"
MACSERIAL="./macserial"
PREV_SETTINGS="$1"
NEW_SETTINGS="$2"

DEFAULT_MLB="C07823609GUKXPGFB"
DEFAULT_SERIAL="C07WT1YGJYVX"
DEFAULT_ECID="0"
DEFAULT_MODEL="Macmini8,1"

if [ -f "$PREV_SETTINGS" ]; then
    SERIAL=`$PLIST_BUDDY -c "Print :PlatformInfo:Generic:SystemSerialNumber" "$PREV_SETTINGS" || echo $DEFAULT_SERIAL`
    MLB=`$PLIST_BUDDY -c "Print :PlatformInfo:Generic:MLB" "$PREV_SETTINGS" || echo $DEFAULT_MLB`
    ECID=`$PLIST_BUDDY -c "Print :Misc:Security:ApECID" "$PREV_SETTINGS" || echo $DEFAULT_ECID`
else
    SERIAL="$DEFAULT_SERIAL"
    MLB="$DEFAULT_MLB"
    ECID="$DEFAULT_ECID"
fi
GENERATED=`$MACSERIAL -a | grep "$DEFAULT_MODEL" | head -1`

if [ "$SERIAL" == "$DEFAULT_SERIAL" ]; then
    echo "Generating new Serial..."
    SERIAL=`echo "$GENERATED" | cut -d '|' -f 2 | xargs`
fi

if [ "$MLB" == "$DEFAULT_MLB" ]; then
    echo "Generating new MLB..."
    MLB=`echo "$GENERATED" | cut -d '|' -f 3 | xargs`
fi

if [ "$ECID" == "$DEFAULT_ECID" ]; then
    echo "Generating new ECID..."
    # 56-bit random number since PlistBuddy doesn't support unsigned 64 bit values
    HEX=`dd if=/dev/urandom bs=7 count=1 2> /dev/null | xxd -p -u`
    ECID=`echo "ibase=16; $HEX" | bc`
fi

echo "Serial: $SERIAL"
$PLIST_BUDDY -c "Set :PlatformInfo:Generic:SystemSerialNumber $SERIAL" "$NEW_SETTINGS"
echo "MLB: $MLB"
$PLIST_BUDDY -c "Set :PlatformInfo:Generic:MLB $MLB" "$NEW_SETTINGS"
echo "ECID: $ECID"
$PLIST_BUDDY -c "Set :Misc:Security:ApECID $ECID" "$NEW_SETTINGS"
