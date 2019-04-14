#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

setup_hardware()
{
    # SSD optimisation
    echo -e "vm.swappiness=0" | sudo tee -a /etc/sysctl.conf
    echo -e "#\x21/bin/sh\\nfstrim -v /" | sudo tee /etc/cron.daily/trim
    chmod +x /etc/cron.daily/trim
}