#!/bin/sh

set -e

# Check target exists
if [ ! -e "$3" ]; then
    echo "$3 volume does not exist!"
    exit 1
fi

# If target volume root of current system then replace
# / with volume name.
if [ "$3" == "/" ]; then
    DEST_VOL="/Volumes/"$( ls -1F /Volumes | sed -n 's:@$::p' )
else
    DEST_VOL="$3"
fi

EFI_ROOT_DIR="${DEST_VOL}"/EFIROOTDIR
OLD_CONFIG="$INSTALLER_TEMP/config.old.plist"

echo "Mounting ESP to $EFI_ROOT_DIR"
./mount_esp.sh "$DEST_VOL" "$EFI_ROOT_DIR"

# Regenerate serial
if [ -f "$INSTALLER_TEMP/regenserial" ]; then
	echo "Saving old config for unique identifiers..."
	cp "$EFI_ROOT_DIR/EFI/OC/config.plist" "$OLD_CONFIG" 2>/dev/null || true
fi

# Backup
if [ -d "$EFI_ROOT_DIR/EFI/OC" ]; then
	if [ -f "$INSTALLER_TEMP/backup" ]; then
		backupRootDir="$DEST_VOL/EFI-Backups" # backup on destination volume (default)
		backupDir="${backupRootDir}/OC/"$( date -j "+%F-%Hh%M" )
		echo "Backing up old OC to $backupDir"
		mkdir -p "$backupDir"
		cp -pR "$EFI_ROOT_DIR/EFI/BOOT/BOOTx64.efi" "${backupDir}/BOOTx64.efi"
		cp -pR "$EFI_ROOT_DIR/EFI/OC" "${backupDir}/OC"
		chflags -R nohidden "$backupDir" # Remove the invisible flag of files in the backups
	else
		echo "Skipping backup of existing OC."
	fi
	rm -rf "$EFI_ROOT_DIR/EFI/OC" # make sure we get a clean install
else
	echo "No existing OC installation found."
fi
