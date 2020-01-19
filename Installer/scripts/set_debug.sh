#!/bin/sh

printf "%s " "keepsyms=1 debug=0x146 watchdog=0 -liludbgall" > "$INSTALLER_TEMP/boot-args-verbose.txt"
