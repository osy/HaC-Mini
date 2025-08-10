#!/bin/sh

touch "$INSTALLER_TEMP/force_io80211family"
touch "$INSTALLER_TEMP/sonoma_wifi_fix"
touch "$INSTALLER_TEMP/intel_sequoia_patch"

printf "%s " "-amfipassbeta" > "$INSTALLER_TEMP/boot-args-sonoma_wifi_fix.txt"

