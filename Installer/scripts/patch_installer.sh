#!/bin/sh

set -e

# In Catalina, we can no longer read external drives so `find $3` no longer 
# works instead we hard code all possible InstallInfo.plist paths and see which
# one exists. This means with every new OSX release, we have to modify this.
SUPPORTED_PATHS="
Install macOS Mojave.app/Contents/SharedSupport/InstallInfo.plist
Install macOS Catalina.app/Contents/SharedSupport/InstallInfo.plist
"
INSTALL_INFO=

while read line; do
    path="$3/$line"
    if [ ! -z "$line" -a -f "$path" ]; then
        echo "Found install info at $path"
        INSTALL_INFO="$path"
    fi
done <<< "$SUPPORTED_PATHS"

if [ -z "$INSTALL_INFO" ]; then
    echo "Cannot find InstallInfo.plist, $3 may not be a valid OSX installer volume"
    echo "Otherwise, this script does not recognize the OSX installer version, here's the known list: $SUPPORTED_PATHS"
    exit 1
fi

PLIST_BUDDY="/usr/libexec/PlistBuddy"
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
