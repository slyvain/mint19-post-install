#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

install_dropbox()
{
    local url="https://linux.dropbox.com/packages/ubuntu/dropbox_2019.02.14_amd64.deb"

    local tmpdir=$( mktemp -d )
    wget --directory-prefix "${tmpdir}" "${url}"

    local filepath="${tmpdir}/$( basename "${url}" )"
    #dpkg --install "${filepath}"

    apt install "${filepath}" -y
}