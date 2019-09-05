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
DEFAULT_UUID="B5E5FF1C-C573-4819-8419-EBF16775B613"
DEFAULT_MODEL="Macmini8,1"

if [ -f "$PREV_SETTINGS" ]; then
	SERIAL=`$PLIST_BUDDY -c "Print :PlatformInfo:Generic:SystemSerialNumber" "$PREV_SETTINGS"`
	MLB=`$PLIST_BUDDY -c "Print :PlatformInfo:Generic:MLB" "$PREV_SETTINGS"`
	UUID=`$PLIST_BUDDY -c "Print :PlatformInfo:Generic:SystemUUID" "$PREV_SETTINGS"`
else
	SERIAL="$DEFAULT_SERIAL"
	MLB="$DEFAULT_MLB"
	UUID="$DEFAULT_UUID"
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

if [ "$UUID" == "$DEFAULT_UUID" ]; then
	echo "Generating new UUID..."
	UUID=`uuidgen`
fi

echo "Serial: $SERIAL"
$PLIST_BUDDY -c "Set :PlatformInfo:Generic:SystemSerialNumber $SERIAL" "$NEW_SETTINGS"
echo "MLB: $MLB"
$PLIST_BUDDY -c "Set :PlatformInfo:Generic:MLB $MLB" "$NEW_SETTINGS"
echo "UUID: $UUID"
$PLIST_BUDDY -c "Set :PlatformInfo:Generic:SystemUUID $UUID" "$NEW_SETTINGS"
