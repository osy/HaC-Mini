#!/bin/sh

set -e

PLIST_BUDDY="/usr/libexec/PlistBuddy"
INSTALL_INFO=`find "$3" -name 'InstallInfo.plist'`
SHARED_SUPPORT=`dirname "$INSTALL_INFO"`

patched=`$PLIST_BUDDY -c "Print :Additional\ Installers" "$INSTALL_INFO" | grep "HaCMini.pkg" || true`
if [ -z "$patched" ]; then
    echo "Patching $INSTALL_INFO"
    $PLIST_BUDDY -c "Add :Additional\ Installers: string HaCMini.pkg" "$INSTALL_INFO"
else
    echo "Skipping patch $INSTALL_INFO, already patched"
fi
echo "Copying package"
cp "$PACKAGE_PATH" "$SHARED_SUPPORT/HaCMini.pkg"
