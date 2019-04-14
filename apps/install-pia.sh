#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

## Install: https://www.privateinternetaccess.com/installer/download_installer_linux_beta
## Uninstall: https://www.privateinternetaccess.com/helpdesk/kb/articles/how-can-i-uninstall-reinstall-your-application-on-linux
install_pia()
{
    local url="https://installers.privateinternetaccess.com/download/pia-linux-1.1.1-02545.run"
    
    # Download the script file in a temp directory
    local tmpdir=$( execute_as_user mktemp -d )
    wget --directory-prefix "${tmpdir}" "${url}"

    # Make the file executable
    local filepath="${tmpdir}/$( basename "${url}" )"
    chmod a+x "${filepath}"
    
    # Execute scritp as current user (without root privilege)
    execute_as_user sh "${filepath}"
}