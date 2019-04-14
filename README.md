# Linux Mint 19.1 Post Installation Script

This script is a very personalized configuration of Linux Mint 19.1.
It uses files from my [Mint 19 Backup](https://github.com/slyvain/mint19-backup) script. 
This is a playground project where I can explore and play around with shell scripting.

### Disclaimer:
This script fitting **my** needs.
It will probably not fit yours.
You are free to use it and modify it but know that you run this script at your own risk! 

## Running the script
The script should be executed as a user with elevated privileges (sudo):
```shell
sudo ./mint19-install.sh
```

## What it does
Two things:
* Install apps
* Configure apps and system

### Installing apps
The script `apps/apps.sh` is in charge of installing all the applications.
The applications to install come in various shape:
There is list of core apps that can be installed via an `apt install`. You can find that list in `apps/packages/core.list`.
A list of Flatpak apps can be found in `apps/packages/flatpak.list`.
I also remove apps I do not use in `apps/packages/remove.list`.
Finally, the applications that require a bit more than a simple install process (get from GitHub, install a ppa, etc.) are found in the `apps/packages` directory and are named `install-{application}.sh`.

### Configuration
The second part of the script configure the applications and the system (desktop, disks, crontab, etc.).
This is obviously the part that is extremly tailor made for my needs.
As mentionned in introduction, most of the files required are downloaded from another GitHub repo: [Mint 19 Backup](https://github.com/slyvain/mint19-backup).
The rest of the config files are found in the directory `config/dumps`.
The script `config/config.sh` calls each config scripts which are named `setup-{config}.sh`.

### Logging
A log fil is created in the Home directory of the logged in user: `~/mint-post-install.log`