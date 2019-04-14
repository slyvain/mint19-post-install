#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

install_filebot()
{
    ## TODO: store this deb somewhere else in case it get removed (newer versions require a paid license)
    local url="https://downloads.sourceforge.net/project/filebot/filebot/FileBot_4.7.9/filebot_4.7.9_amd64.deb"
    
    # Download the deb package in a temp directory
    local tmpdir=$( mktemp -d )
    wget --directory-prefix "${tmpdir}" "${url}"

    # Install package
    local filepath="${tmpdir}/$( basename "${url}" )"
    #dpkg --install "${filepath}"
    apt install "${filepath}"
}