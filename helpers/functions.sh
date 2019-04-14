#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly DECRYPTED_FILE="${0%/*}/config/dumps/private.txt"

: << 'SUMMARY'
Execute a command line as the logged in user in order to
prevent root ownership as the script is intended to be ran by root
SUMMARY
execute_as_user()
{
    sudo -u "$(logname)" "$@"
}


: << 'SUMMARY'
Decrypt the private data stored in the GPG encrypted file.
To decrypt the file, the passphrase must be given as the first and only argument to the script.
Don't remember the passphrase? Check Keeweb!
SUMMARY
decrypt_file()
{
    local filename="private.bak.gpg"
    local file_url="${BACKUP_REPO}/${filename}"

    log_info "Download encrypted file from GitHub"

    # the logged in user should create the tmp dir so that we can copy and decrypt the file from there
    local tmpdir=$( execute_as_user mktemp -d )
    wget --directory-prefix "${tmpdir}" "${file_url}"
    
    local tmpurl="${tmpdir}/${filename}"

    if [[ ! -f "${tmpurl}" ]] ; then
        log_error "Could not find encrypted private data file in '${tmpurl}'."
        exit 1
    fi

    log_info "Encrypted file downloaded!"

    log_warning "Passphrase required to decrypt the private data file!"
    log_warning "(check Keeweb if necessary)"
    read -r userinput
    if [[ -z ${userinput} ]]; then
        log_error "Error: No passphrase entered! Exiting..."
        exit 1
    else
        execute_as_user gpg --batch --passphrase "${userinput}" --output "${DECRYPTED_FILE}" --decrypt "${tmpurl}"
    fi
    
    if [[ ! -f "${DECRYPTED_FILE}" ]] ; then
        log_error "Cannot find decrypted private data file!"
        exit 1
    else
        log_success "Private data successfully decrypted."
    fi
}


: << 'SUMMARY'
Check whether the private data file already exists and ask the user whether to overwrite it or not.
If the file doesn't exists, or if the use chose to overwrite, the script will ask for the passphrase
to decrypt the file.
SUMMARY
decrypt_private_data()
{
    if [[ -f "${DECRYPTED_FILE}" ]]; then
        echo "Private data file already exists."
        echo "Overwrite? [y-n]"
        read -r userinput
        if [[ "y" = "${userinput}" ]]; then
            rm "${DECRYPTED_FILE}"
            decrypt_file
        elif [[ "n" != "${userinput}" ]]; then
            echo "Error: You typed '${userinput}', pay attention! Exiting..."
            exit 1
        fi
    else
        decrypt_file
    fi
}


: << 'SUMMARY'
Get the plain text private data from the decrypted GPG file.
Accept one argument: the key from the key-value-pair private data file.
A single global variable "DECRYPTED_RESULT" is used throughout the script to "return" the
value corresponding to the given argument.
SUMMARY
get_decrypted_data()
{
    export DECRYPTED_RESULT=$( sed -n "s/^${1}:\(.*\)/\1/p" "${DECRYPTED_FILE}" )
}