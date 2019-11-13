#!/bin/bash

DEST_VOL="${1}"
EFI_ROOT_DIR="${2:-${DEST_VOL%*/}/EFIROOTDIR}"
partutil="./partutil"
espfinder="./espfinder"

DiskDevice=$(LC_ALL=C diskutil info "${DEST_VOL}" 2>/dev/null | \
                              sed -n 's/.*Part [oO]f Whole: *//p')

if [[ -z "$DiskDevice" ]]; then
    echo "Can't find volume with the name ${DEST_VOL}"
    exit 1
fi

# check if target volume is a logical Volume instead of physical
if [[ "$(echo $(LC_ALL=C diskutil list | grep -i 'Logical Volume' | \
          awk '{print tolower($0)}'))" == *"logical volume"* ]]; then
    # ok, we have a logical volume somewhere.. so that can assume that we can use "diskutil cs"
    LC_ALL=C diskutil cs info $DiskDevice > /dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
        # logical volumes does not have an EFI partition (or not suitable for us?)
        echo "$DiskDevice is a logical volume"
        # find the partition uuid
        UUID=$(LC_ALL=C diskutil info "${DiskDevice}" 2>/dev/null | \
                                      sed -n 's/.*artition UUID: *//p')
        # with the partition uuid we can find the real disk in in diskutil list output
        if [[ -n "$UUID" ]]; then
            realDisk=$(LC_ALL=C diskutil list | \
                grep -B 1 "$UUID" | \
                grep -i 'logical volume' | awk '{print $4}' | \
                sed -e 's/,//g' | sed -e 's/ //g')
            if [[ -n "$realDisk" ]]; then
                DiskDevice=$(LC_ALL=C diskutil info "${realDisk}" 2>/dev/null | \
                                             sed -n 's/.*Part [oO]f Whole: *//p')
            fi
        fi
    fi
fi

# check if target volume is APFS, and therefore part of an APFS container
if [[ "$(echo $(LC_ALL=C diskutil list "$DiskDevice" | grep -i 'APFS Container Scheme' | \
          awk '{print tolower($0)}'))" == *"apfs container scheme"* ]]; then
    # ok, this disk is an APFS partition, extract physical store device
    realDisk=$(LC_ALL=C diskutil list "$DiskDevice" 2>/dev/null | \
        sed -n 's/.*Physical Store *//p')
    echo Target volume "$1" on "$DiskDevice" is APFS on physical store "$realDisk"
    DiskDevice=$(LC_ALL=C diskutil info "$realDisk" 2>/dev/null | \
        sed -n 's/.*Part [oO]f Whole: *//p')
fi

# check one more time for RAID.
if [[ ! -z "$(echo $(LC_ALL=C diskutil ar list | grep "$DiskDevice$"))" ]]; then
  realDisk="$(diskutil ar list | grep -A 10 "${DiskDevice}$" | sed -n 's/Online//p' | head -1 | sed 's/[0-9]*[ ]*\([^ ]*\)[ ]*.*$/\1/g')"
  # Find first online disk.
  echo Target volume "$1" on "$DiskDevice" is RAID on physical store "$realDisk"
  DiskDevice=$(LC_ALL=C diskutil info "$realDisk" 2>/dev/null | \
  sed -n 's/.*Part [oO]f Whole: *//p')
fi


# echo "realDisk = $realDisk"
# echo "UUID = $UUID"
# echo "DiskDevice = $DiskDevice"

# Check if the disk is a GPT disk
disk_partition_scheme=$("$partutil" --show-partitionscheme "$DiskDevice")

if [[ "$disk_partition_scheme" == "GUID_partition_scheme" ]]; then

    plistbuddy='/usr/libexec/PlistBuddy'

    # Get the index of the ESP device
    index=$(LC_ALL=C /usr/sbin/gpt -r show "/dev/$DiskDevice" 2>/dev/null | \
     awk 'toupper($7) == "C12A7328-F81F-11D2-BA4B-00A0C93EC93B" {print $3; exit}')
    [[ -z "$index" ]] && index=1 # if not found use the index 1



    if [[ -e /useespfinder ]]; then
        echo "using espfinder" > /useespfinder
        ESPDevice=$("$espfinder" -t "${DEST_VOL}")
        if [[ "$ESPDevice" != disk* ]]; then
            ESPDevice="${DiskDevice}s${index}"
        fi
    else
        # Define the ESPDevice
        ESPDevice="${DiskDevice}s${index}"
    fi

    # Get the ESP mount point if the partition is currently mounted
    ESPMountPoint=$("$partutil" --show-mountpoint "$ESPDevice")

    if [[ -n "$ESPMountPoint" ]]; then
        # If already mounted it's okay
        exitcode=0
    else
        # Else try to mount the ESP partition
        ESPMountPoint="/Volumes/ESP"
        exitcode=1
        fstype=$($partutil --show-fstype $ESPDevice)
        if [[ -n "$fstype" ]]; then
            [[ ! -d "${ESPMountPoint}" ]] && mkdir -p "${ESPMountPoint}"
            mount -t $fstype /dev/$ESPDevice "${ESPMountPoint}" 2>&1
            exitcode=$?
        fi
    fi

    if [[ $exitcode -ne 0 ]]; then
        echo
        echo "ERROR: can't mount ESP partition ($ESPDevice) !"
        echo "Check that the partition is well formated in HFS or Fat32."
        echo
        echo "To format as HFS use command like:"
        echo "sudo newfs_hfs -v EFI /dev/r$ESPDevice"
        echo
        echo "For format as Fat32 use command like:"
        echo "sudo newfs_msdos -v EFI -F 32 /dev/r$ESPDevice"
    else
        ln -sf "$ESPMountPoint" "$EFI_ROOT_DIR"
    fi
else
    # error if not GPT
    echo "Partition is ${disk_partition_scheme}, not GUID_partition_scheme!"
    exitcode=1
fi

exit $exitcode
