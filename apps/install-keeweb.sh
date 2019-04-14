#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

install_keeweb()
{
    # Get the latest 64x version of Keeweb on Github
    local url=$( curl -s "https://api.github.com/repos/keeweb/keeweb/releases/latest" |
        grep browser_download_url |
        grep '64[.]deb' |
        head -n 1 |
        cut -d '"' -f 4 )

    # Download the deb package in a temp directory
    local tmpdir=$( mktemp -d )
    wget --directory-prefix "${tmpdir}" "${url}"
    
    # Install required dependency (Keeweb install would fail without)
    #apt-get --yes install libgconf2-4

    # Install package
    local filepath="${tmpdir}/$( basename "${url}" )"
    #dpkg --install "${filepath}"

    apt install "${filepath}" -y
}