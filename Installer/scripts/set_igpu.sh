#!/bin/sh

rm -f /Library/Preferences/com.apple.AppleGVA.plist
printf "%s " "shikigva=32 shiki-id=Mac-BE088AF8C5EB4FA2 igfxmetal=1" > "$INSTALLER_TEMP/boot-args-gpu.txt"
