#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasRvm() {
    which rvm >/dev/null && [[ $(which rvm | grep -ic "not found") -eq "0" ]]
}

function hasRuby() {
    which ruby >/dev/null && [[ $(which ruby | grep -ic "not found") -eq "0" ]]
}

function installRvm() {
    printf "${BLUE}[-] Installing rvm...${NC}\n"
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
}

function uninstallRvm() {
    printf "${BLUE}[-] Uninstalling rvm...${NC}\n"
    rm -rf ~/.rvm
    sedi '/\.rvm\/bin/d' ~/.bashrc
    sedi '/\.rvm\//d' ~/.bash_profile
}

function installRuby() {
    version=${1-'2.5.0'}

    if ! hasRvm; then
        installRvm
    fi

    printf "${BLUE}[-] Installing ruby ${version}...${NC}\n"
    rvm install ${version}
    rvm --default use ${version}
}

function uninstallRuby() {
    uninstallRvm
}
