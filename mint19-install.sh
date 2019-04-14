#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly HOMEDIR=$( getent passwd "$(logname)" | cut -d: -f6 )
readonly LOGFILE="${HOMEDIR}/mint-post-install.log"
readonly BACKUP_REPO="https://github.com/slyvain/mint19-backup/raw/master/dumps"

readonly LOG_DEFAULT_COLOR="\033[0m"
readonly LOG_INFO_COLOR="\033[1;94m"
readonly LOG_ERROR_COLOR="\033[1;31m"
readonly LOG_SUCCESS_COLOR="\033[1;32m"
readonly LOG_WARNING_COLOR="\033[1;33m"

main()
{
    initialize_script

    log_info "Start install script."

    # Install & remove apps
    source "${0%/*}/apps/apps.sh"
    install_apps

    # Setup system configuration
    source "${0%/*}/config/config.sh"
    configure_system

    log_info "End install script."
}

initialize_script()
{
    # Source the useful functions
    source "${0%/*}/helpers/functions.sh"
    
    # Source and initialize the logs
    source "${0%/*}/helpers/logs.sh"
    init_log

    # Decrypt the private data from the GPG encrypted file
    decrypt_private_data
}

# Make sure the script is ran by root
if [[ $(/usr/bin/id -u) -eq 0 ]]; then
    main "$@"
else
    echo "Not running as root"
    exit 1
fi

exit 0