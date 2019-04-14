#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

install_unetbootin()
{
    add-apt-repository ppa:gezakovacs/ppa -y
    apt-get update
    apt-get install unetbootin -y
}