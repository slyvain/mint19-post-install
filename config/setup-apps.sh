#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

: << 'SUMMARY'
    Setup Plank to start automatically.
    Load different settings files to add the apps to Plank.
SUMMARY
setup_plank()
{
    # Start and stop Plank to be able to create the settings (important: run in background!)
    execute_as_user plank &

    local tmpdir=$( execute_as_user mktemp -d )

    # Setup autostart in ~/.config/autostart/plank.desktop
    wget --directory-prefix "${tmpdir}" "${BACKUP_REPO}/plank-autostart.bak"
    execute_as_user cp "${tmpdir}/plank-autostart.bak" "${HOMEDIR}/.config/autostart/plank.desktop"

    # Delete existing launchers and set mine (doesn't work great though... don't know why)
    wget --directory-prefix "${tmpdir}" "${BACKUP_REPO}/plank-launchers.tar.gz"
    execute_as_user tar -xf "${tmpdir}/plank-launchers.tar.gz" --directory "${HOMEDIR}/.config/plank/dock1/launchers/"

    # Get and set the theme
    wget --directory-prefix "${tmpdir}" "https://raw.githubusercontent.com/KenHarkey/plank-themes/master/paperterial/dock.theme"
    local paperterial_dir="${HOMEDIR}/.local/share/plank/themes/Paperterial"
    if [[ -d "${paperterial_dir}" ]] ; then
        rm -r "${paperterial_dir}"
    fi
    execute_as_user mkdir "${paperterial_dir}"
    execute_as_user mv "${tmpdir}/dock.theme" --target-directory "${paperterial_dir}/"

    # Set Plank's settings for current user
    wget --directory-prefix "${tmpdir}" "${BACKUP_REPO}/plank-settings.bak"
    execute_as_user dconf load /net/launchpad/plank/ < "${tmpdir}/plank-settings.bak"
}


: << 'SUMMARY'
    Set Git username and email, also choose nano as default editor.
    Write Github credentials in "store" to prevent VSCode to ask for the 2FA token after every pull/push.
SUMMARY
setup_git()
{
    # Get the private data
    get_decrypted_data "github_username"
    local github_username="${DECRYPTED_RESULT}"
    get_decrypted_data "github_email"
    local github_email="${DECRYPTED_RESULT}"

    # https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config
    git config --global user.name "${github_username}"
    git config --global user.email "${github_email}"
    git config --system core.editor "nano -w"
    # will store plain credentials in ~/.git-credentials
    # https://git-scm.com/docs/git-credential-store
    git config --global credential.helper store
    git config --global push.default simple
}


: << 'SUMMARY'
    Setup Filebot user credentials for OpenSubtitlesDB.
SUMMARY
setup_filebot()
{
    # Get the private data
    get_decrypted_data "filebot_username"
    local filebot_username="${DECRYPTED_RESULT}"
    get_decrypted_data "filebot_password"
    local filebot_password="${DECRYPTED_RESULT}"

    filebot -script fn:configure --def osdbUser="${filebot_username}" osdbPwd="${filebot_password}"
}


: << 'SUMMARY'
    Setup Transmission with personalized settings.
SUMMARY
setup_transmission()
{
    local confdir="${HOMEDIR}/.config/transmission"
    
    # It shouldn't exist but hey...
    if [[ -d "${confdir}" ]] ; then
        if [[ -f "${confdir}/settings.json" ]] ; then
            log_warning "Settings.json already exists, a copy has been created!"
            execute_as_user cp "${confdir}/settings.json" "${confdir}/settings.json.bak"
        fi
    else
        execute_as_user mkdir "${confdir}"
        log_info "Transmission config directory created"
    fi

    # Create or overwrite file
    local tmpdir=$( execute_as_user mktemp -d )
    wget --directory-prefix "${tmpdir}" "${BACKUP_REPO}/transmission.bak"
    execute_as_user cp "${tmpdir}/transmission.bak" "${confdir}/settings.json"
}


: << 'SUMMARY'
    Call the apps setup local functions.
SUMMARY
setup_apps()
{
    setup_plank
    setup_git
    setup_filebot
    setup_transmission
}