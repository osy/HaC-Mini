#!/bin/sh

set -e

# If target volume root of current system then replace
# / with volume name.
if [ "$3" == "/" ]; then
    DEST_VOL="/Volumes/"$( ls -1F /Volumes | sed -n 's:@$::p' )
else
    DEST_VOL="$3"
fi

DEST_TMP="${DEST_VOL}/private/tmp"
EFI_ROOT_DIR="${DEST_TMP}/EFIROOTDIR"
OLD_CONFIG="$INSTALLER_TEMP/config.old.plist"
NEW_CONFIG="$EFI_ROOT_DIR/EFI/OC/config.plist"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

# Regenerate serial
if [ ! -f "$INSTALLER_TEMP/regenserial" ]; then
    echo "Saving old config for unique identifiers..."
    cp "$INSTALLER_TEMP/Old/OC/config.plist" "$OLD_CONFIG" 2>/dev/null || true
fi

# Backup
if [ -d "$INSTALLER_TEMP/Old" ]; then
    if [ -f "$INSTALLER_TEMP/backup" ]; then
        backupRootDir="$DEST_VOL/Library/EFI-Backups" # backup on destination volume (default)
        backupDir="${backupRootDir}/OC/"$( date -j "+%F-%Hh%M" )
        echo "Backing up old OC to $backupDir"
        mkdir -p "$backupDir"
        mv "$INSTALLER_TEMP/Old/BOOT/BOOTx64.efi" "${backupDir}/BOOTx64.efi"
        mv "$INSTALLER_TEMP/Old/OC" "${backupDir}/OC"
        chflags -R nohidden "$backupDir" # Remove the invisible flag of files in the backups
    else
        echo "Skipping backup of existing OC."
    fi
fi

# Install boot-args
bootargs=`$PLIST_BUDDY -c "Print :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args" "$NEW_CONFIG"`
addargs=`find "$INSTALLER_TEMP" -name 'boot-args-*.txt' -type f -depth 1 -exec cat \{\} \;`
bootargs="$bootargs $addargs"
echo "Setting default boot-args=$bootargs"
$PLIST_BUDDY -c "Set :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args $bootargs" "$NEW_CONFIG"

if [ -f "$INSTALLER_TEMP/showpicker" ]; then
    echo "Enabling picker menu"
    $PLIST_BUDDY -c "Add :Misc:Boot:ShowPicker bool true" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Misc:Boot:Timeout integer 5" "$NEW_CONFIG"
fi

# Add files to config
echo "Installing drivers"
./install_drivers.sh "$NEW_CONFIG" "$EFI_ROOT_DIR/EFI/OC/Drivers"
echo "Installing ACPI"
./install_acpi.sh "$NEW_CONFIG" "$EFI_ROOT_DIR/EFI/OC/ACPI"
echo "Installing kexts"
./install_kexts.sh "$NEW_CONFIG" "$EFI_ROOT_DIR/EFI/OC/Kexts"

if [ -f "$INSTALLER_TEMP/force_io80211family" ]; then
    echo "Forcing IO80211Family to load on boot"
    $PLIST_BUDDY -c "Add :Kernel:Force array" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Force:0 dict" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Force:0:Arch string Any" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Force:0:BundlePath string System/Library/Extensions/IO80211Family.kext" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Force:0:Enabled bool true" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Force:0:Identifier string com.apple.iokit.IO80211Family" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Force:0:ExecutablePath string Contents/MacOS/IO80211Family" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Add :Kernel:Force:0:PlistPath string Contents/Info.plist" "$NEW_CONFIG"
fi

echo "Setting up unique identifiers..."
./copy_serial.sh "$OLD_CONFIG" "$NEW_CONFIG"

if [ -f "$INSTALLER_TEMP/security" ]; then
    echo "Setting secure boot settings..."
    $PLIST_BUDDY -c "Set :Misc:Security:Vault Secure" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Set :Misc:Security:SecureBootModel Default" "$NEW_CONFIG"
    echo "Generating secure vault..."
    ./sign.command "$EFI_ROOT_DIR/EFI/OC"
    rm -rf "$EFI_ROOT_DIR/EFI/OC/Keys" # make sure to delete the private keys
else
    echo "Skipping secure vault generation."
fi

echo "Unmounting ESP..."
diskutil unmount "$EFI_ROOT_DIR"
rm -f "$EFI_ROOT_DIR"

if [ -f "$INSTALLER_TEMP/faketmp" ]; then
    rmdir -p "$DEST_TMP" || true
fi
