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

# Backup
if [ -d "$EFI_ROOT_DIR/EFI/OC" ]; then
	cp -pR "$EFI_ROOT_DIR/EFI" "$INSTALLER_TEMP/Old"
	rm -rf "$EFI_ROOT_DIR/EFI/OC" # make sure we get a clean install
else
	echo "No existing OC installation found."
fi
