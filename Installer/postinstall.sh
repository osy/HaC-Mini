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

echo "Setting up unique identifiers..."
./copy_serial.sh "$OLD_CONFIG" "$NEW_CONFIG"

if [ -f "$INSTALLER_TEMP/security" ]; then
    echo "Setting secure boot settings..."
    $PLIST_BUDDY -c "Set :Misc:Security:RequireSignature true" "$NEW_CONFIG"
    $PLIST_BUDDY -c "Set :Misc:Security:RequireVault true" "$NEW_CONFIG"
	echo "Generating secure vault..."
	./sign_oc.sh "$EFI_ROOT_DIR/EFI/OC"
else
	echo "Skipping secure vault generation."
fi

echo "Unmounting ESP..."
diskutil unmount "$EFI_ROOT_DIR"
rm -f "$EFI_ROOT_DIR"

if [ -f "$INSTALLER_TEMP/faketmp" ]; then
    rmdir -p "$DEST_TMP" || true
fi
