#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly DUMPDIR="${0%/*}/config/dumps"

configure_system()
{
    shopt -s nullglob
    local confScriptList=( ${0%/*}/config/setup-*.sh )

    # Run all config scripts
    for script in "${confScriptList[@]}"; do
        source "$script"
        config=$( sed -e 's/.*setup-\(.*\).sh/\1/' <<< "${script}" )
        
        log_info "Configuring ${config}"
        setup_"${config}"
        log_success "${config} successfully configured"
    done
}