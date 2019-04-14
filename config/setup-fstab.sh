#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

setup_fstab()
{
    local fstab="/etc/fstab"

    # Add "noatime" to the system SSD
    sed --in-place 's/remount-ro/&,noatime/g' "${fstab}"

    # Add automount for the other disks
    cat "${DUMPDIR}/fstab.bak" >> "${fstab}"
}