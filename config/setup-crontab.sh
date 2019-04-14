#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

setup_crontab()
{
    local tmpdir=$( execute_as_user mktemp -d )

    wget --directory-prefix "${tmpdir}" "${BACKUP_REPO}/crontab.bak"

    # Replace the default email address with mine
    get_decrypted_data "crontab_email"
    local crontab_email="${DECRYPTED_RESULT}"
    sed -in-place "s/^MAILTO=\(.*\)$/MAILTO=${crontab_email}/g" "${tmpdir}/crontab.bak"

    # Write in logged user's crontab
    crontab -u "$(logname)" "${tmpdir}/crontab.bak"
}