#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

## https://www.virtualbox.org/wiki/Linux_Downloads
install_virtualbox()
{
    # Get Ubuntu codename (for Mint 19, it should be "bionic")
    local dist=$( sed 's/UBUNTU_CODENAME=//;t;d' "/etc/os-release" ) 

    # Add the repository
    echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian ${dist} contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

    # Add the VirtualVox signing keys
    wget --quiet https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    wget --quiet https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

    apt-get update

    # Create entry in /etc/apt/sources.list.d/virtualbox.list
    apt-get install -y virtualbox-6.0
}