#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

setup_home()
{
    local directories=("Music" "Templates" "Videos")
    local bookmarks="${HOMEDIR}/.config/gtk-3.0/bookmarks"
    local userdirs="${HOMEDIR}/.config/user-dirs.dirs"

    if [[ -f "${bookmarks}" ]] ; then
        log_warning "Cannot find the bookmarks file at '${bookmarks}'!"
    fi

    if [[ -f "${userdirs}" ]] ; then
        log_warning "Cannot find the user-dirs file at '${userdirs}'!"
    fi

    for dir in "${directories[@]}"; do
        dirpath="${HOMEDIR}/${dir}"

        if [[ -d "${dirpath}" ]] ; then
            # Delete the directory and remove it from the bookmarks
            rm -rf "${dirpath}"

            # Delete the line containing the folder name
            if [[ -f "${bookmarks}" ]] ; then
                sed --in-place "/${dir}/d" "${bookmarks}"
            fi

            # Delete the line containing the folder name
            if [[ -f "${userdirs}" ]] ; then
                sed --in-place "/${dir}/d" "${userdirs}"
            fi
        else
            log_warning "Could not find directory ${dirpath}"
        fi
    done
}

setup_wallpapers()
{
    local archive="${BACKUP_REPO}/wallpapers.tar.gz"
    local tmpdir=$( execute_as_user mktemp -d )
    wget --directory-prefix "${tmpdir}" "${archive}"

    local dest_directory="${HOMEDIR}/Pictures/Wallpapers"

    if [[ -d "${dest_directory}" ]] ; then
        rm -r "${dest_directory}"
    fi
    execute_as_user mkdir "${dest_directory}"
    execute_as_user tar -xf "${tmpdir}/wallpapers.tar.gz" --directory "${dest_directory}/"
}

setup_numix_icons()
{
    apt-add-repository ppa:numix/ppa -y
    apt update
    apt install numix-icon-theme-circle -y

    # Set icons in theme
    execute_as_user dconf write /org/cinnamon/desktop/interface/icon-theme "'Numix-Circle'"
}

setup_cinnamon()
{
    local tmpdir=$( execute_as_user mktemp -d )

    local general_settings="${BACKUP_REPO}/cinnamon.bak"
    wget --directory-prefix "${tmpdir}" "${general_settings}"
    execute_as_user dconf load /org/cinnamon/ < "${tmpdir}/cinnamon.bak"

    local calendar_settings="${BACKUP_REPO}/cinnamon-calendar.bak"
    wget --directory-prefix "${tmpdir}" "${calendar_settings}"
    execute_as_user cp "${tmpdir}/cinnamon-calendar.bak" "${HOMEDIR}/.cinnamon/configs/calendar@cinnamon.org/11.json" 

    local menu_settings="${BACKUP_REPO}/cinnamon-menu.bak"
    wget --directory-prefix "${tmpdir}" "${menu_settings}"
    execute_as_user cp "${tmpdir}/cinnamon-menu.bak" "${HOMEDIR}/.cinnamon/configs/menu@cinnamon.org/1.json" 

    # Reboot required! Do not run the `cinnamon --replace` command: it freezes on my machines!
}

setup_desktop()
{
    setup_home
    setup_cinnamon
    setup_wallpapers
    setup_numix_icons
}