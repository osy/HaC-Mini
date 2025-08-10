#!/bin/sh

touch "$INSTALLER_TEMP/sonoma_wifi_fix"

printf "%s " "-amfipassbeta" > "$INSTALLER_TEMP/boot-args-sonoma_wifi_fix.txt"

