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
