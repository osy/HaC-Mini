#!/bin/sh

set -e

TMPDIR="$INSTALLER_TEMP"
DISK_IMAGE=`find "$3" -name 'InstallESD.dmg'`
INSTALL_PLIST="`dirname "$DISK_IMAGE"`/InstallInfo.plist"
MOUNT_POINT="$TMPDIR/InstallESD"
SHADOW_FILE="$TMPDIR/InstallESD.shadow"
PKG_EXPAND="$TMPDIR/OSInstall"
SELF_EXPAND="$TMPDIR/Self"
TMP_DMG="$TMPDIR/InstallESD.dmg"

echo "Extracting core package from self"
rm -rf "$SELF_EXPAND"
pkgutil --expand "$PACKAGE_PATH" "$SELF_EXPAND"

echo "Mounting $DISK_IMAGE to $MOUNT_POINT"
rm -rf "$SHADOW_FILE"
hdiutil attach -shadow "$SHADOW_FILE" -mountpoint "$MOUNT_POINT" -nobrowse -owners on "$DISK_IMAGE"

echo "Expanding OSInstall.mpkg"
rm -rf "$PKG_EXPAND"
pkgutil --expand "$MOUNT_POINT/Packages/OSInstall.mpkg" "$PKG_EXPAND"

if [ -d "$MOUNT_POINT/Packages/HaCMiniCore.pkg" ]; then
    echo "Existing patch found, overwriting core pkg"
    rm -rf "$MOUNT_POINT/Packages/HaCMiniCore.pkg"
    cp -r "$SELF_EXPAND/HaCMiniCore.pkg" "$MOUNT_POINT/Packages/HaCMiniCore.pkg"
    echo "Skipping Distribution XML patches"
else
    echo "Patching installer package"
    cp -r "$SELF_EXPAND/HaCMiniCore.pkg" "$MOUNT_POINT/Packages/HaCMiniCore.pkg"
    sed '/pkg-ref.*id="com\.apple\.pkg\.Core".*auth="Root"/a\
    <pkg-ref id="com.osy86.hacmini.core" auth="Root" packageIdentifier="com.osy86.hacmini.core">#HaCMiniCore.pkg</pkg-ref>
    /pkg-ref.*id="com\.apple\.pkg\.Core".*installKBytes/a\
    <pkg-ref id="com.osy86.hacmini.core" installKBytes="0" version="2.0"/>
    ' "$PKG_EXPAND/Distribution" > "$TMPDIR/Distribution"
    mv "$TMPDIR/Distribution" "$PKG_EXPAND/Distribution"
fi

echo "Re-creating OSInstall.mpkg"
pkgutil --flatten "$PKG_EXPAND" "$MOUNT_POINT/Packages/OSInstall.mpkg"

echo "Unmounting $DISK_IMAGE"
hdiutil detach "$MOUNT_POINT"

echo "Converting shadow image to $TMP_DMG"
rm -rf "$TMP_DMG"
hdiutil convert -format UDRO -o "$TMP_DMG" -shadow "$SHADOW_FILE" "$DISK_IMAGE"

echo "Overwriting original image"
mv "$TMP_DMG" "$DISK_IMAGE"
rm -f "$INSTALL_PLIST" # required to bypass "corrupt installer" issue
