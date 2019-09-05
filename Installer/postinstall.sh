#!/bin/sh

set -e

# If target volume root of current system then replace
# / with volume name.
if [ "$3" == "/" ]; then
    DEST_VOL="/Volumes/"$( ls -1F /Volumes | sed -n 's:@$::p' )
else
    DEST_VOL="$3"
fi

EFI_ROOT_DIR="${DEST_VOL}"/EFIROOTDIR
OLD_CONFIG="$INSTALLER_TEMP/config.old.plist"

# Regenerate serial
if [ ! -f "$INSTALLER_TEMP/regenserial" ]; then
    echo "Saving old config for unique identifiers..."
    cp "$INSTALLER_TEMP/Old/OC/config.plist" "$OLD_CONFIG" 2>/dev/null || true
fi

# Backup
if [ -d "$INSTALLER_TEMP/Old" ]; then
    if [ -f "$INSTALLER_TEMP/backup" ]; then
        backupRootDir="$DEST_VOL/EFI-Backups" # backup on destination volume (default)
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
./copy_serial.sh "$OLD_CONFIG" "$EFI_ROOT_DIR/EFI/OC/config.plist"

if [ -f "$INSTALLER_TEMP/security" ]; then
	echo "Generating secure vault..."
	./sign_oc.sh "$EFI_ROOT_DIR/EFI/OC"
else
	echo "Skipping secure vault generation."
fi

echo "Unmounting ESP..."
umount "$EFI_ROOT_DIR"
rm -f "$EFI_ROOT_DIR"
