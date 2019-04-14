#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

install_chrome()
{
    # Install Google signing key (see: https://www.google.com/linuxrepositories/)
    wget --quiet --output-document - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

    local url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    
    # Download the deb package in a temp directory
    local tmpdir=$( mktemp -d )
    wget --directory-prefix "${tmpdir}" "${url}"

    # Install package (it will also create entry in /etc/apt/sources.list.d/google-chrome.list)
    local filepath="${tmpdir}/$( basename "${url}" )"
    #dpkg --install "${filepath}"
    apt install "${filepath}" -y
}
