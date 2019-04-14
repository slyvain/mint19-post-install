#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

log()
{
    local message="$1"
    local level="$2"
    local color="$3"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo -e "$timestamp ${color}[${level}] $message ${LOG_DEFAULT_COLOR}"
    echo -e "$timestamp [${level}] $message" >> "${LOGFILE}"
    return 0
}

log_info()
{
    log "$1" "INFO" "$LOG_INFO_COLOR" 
}

log_success() 
{ 
    log "$1" "SUCCESS" "$LOG_SUCCESS_COLOR" 
}

log_warning()
{
    log "$1" "WARNING" "$LOG_WARNING_COLOR" 
}

log_error() 
{
    log "$1" "ERROR" "$LOG_ERROR_COLOR"
}

init_log()
{
    if [[ -f "${LOGFILE}" ]] ; then
        rm "${LOGFILE}"
    fi

    execute_as_user touch "${LOGFILE}"
    
    if [[ -f "${LOGFILE}" ]] ; then
        log_success "Log file created in '${LOGFILE}'"
    else
        log_error "Cannnot create log file!"
        exit 1
    fi  
}