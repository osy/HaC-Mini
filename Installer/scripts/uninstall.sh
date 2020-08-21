#!/bin/sh

set -e

DEST_VOL="$1"
OLD_FILES="
/usr/local/bin/SLForceFPS
/Library/LaunchAgents/com.osy86.SLForceFPS.plist
/Library/Preferences/com.apple.AppleGVA.plist
"

while read line; do
    path="$DEST_VOL/$line"
    if [ ! -z "$line" -a -f "$path" ]; then
        echo "Removing $path"
        rm -f "$path"
    fi
done <<< "$OLD_FILES"
