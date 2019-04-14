#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

declare -r APPDIR="${0%/*}/apps"

update_all()
{
    log_info "Update list of packages and install new versions"
    apt update && apt upgrade -y
    log_success "Packages successfully updated"
}

install_core_apps()
{
    log_info "Installing Linux core applications..."

    readarray -t apps < "${APPDIR}/packages/core.list"

    for app in "${apps[@]}"; do
        log_info "Installing ${app^}..."
        apt-get --yes install "${app}"
        log_success "${app^} successfully installed"
    done
    
    log_success "Core applications successfully installed"
}

install_remote_apps()
{
    log_info "Installing remote applications..."

    shopt -s nullglob
    local appScriptList=("${APPDIR}"/install-*.sh)

    for script in "${appScriptList[@]}"; do
        source "${script}"
        # Extract app name from the script name
        app=$( sed -e 's/.*install-\(.*\).sh/\1/' <<< "${script}" )
        
        log_info "Installing ${app^}..."
        install_"${app}"
        log_success "${app^} successfully installed"
    done

    log_success "Remote applications successfully installed"
}

install_snap_apps()
{
    log_info "Installing Snap applications..."

    readarray -t apps < "${APPDIR}/packages/snap.list"

    for app in "${apps[@]}"; do
        log_info "Installing Snap app ID ${app^}..."
        snap install --classic "${app}"
        log_success "Snap ${app^} successfully installed"
    done

    log_success "Snap applications successfully installed"
}

remove_unused()
{
    log_info "Removing unused applications..."

    readarray -t apps < "${APPDIR}/packages/remove.list"

    for app in "${apps[@]}"; do
        log_info "Removing ${app^}..."
        apt-get purge --autoremove -y "${app}"
        log_success "${app^} is deleted"
    done

    log_success "Unused applications successfully removed"
}

cleanup()
{
    # Install missing dependencies
    log_info "Installing missing dependencies..."
    apt-get --fix-broken --yes install
    # One last update before cleaning
    log_info "Update and upgrade apps..."
    update_all
    # And clean up
    log_info "Cleaning up orphan packages and cache..."
    apt autoremove --purge && apt clean -y
}

install_apps()
{
    update_all
    install_core_apps
    install_remote_apps
    install_snap_apps
    remove_unused
    cleanup
}
