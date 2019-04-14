#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

setup_grub()
{
    local grub="/etc/default/grub"

    # Change GRUB timeout from 10 to 3 seconds
    sed -i 's/GRUB_TIMEOUT=10/aGRUB_TIMEOUT=3/g' "${grub}"

    # Important: update!
    update-grub
}