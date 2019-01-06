#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"
source "./src/ruby.sh"

BREW_PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
BREW_UMASK="umask 002"

BREW_OS_DEPENDENCIES="build-essential curl g++ file git m4 texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev gawk make patch tcl"

function setupBrewOS() {
    sudo apt-get update -y &&
        sudo apt-get update --fix-missing -y &&
        sudo apt-get install --no-install-recommends ${BREW_OS_DEPENDENCIES} -y &&
        sudo apt autoremove -y
    installRuby
}

function purgeBrewOS() {
    sudo apt-get remove --purge ${BREW_OS_DEPENDENCIES} -y &&
        sudo apt autoremove -y
    uninstallRuby
}

function hasBrew() {
    which brew >/dev/null && [[ $(which brew | grep -ic "not found") -eq "0" ]]
}

function hasBrewPathConfig() {
    cat ~/.bashrc | grep -icq "${BREW_PATH}"
}

function hasBrewUmaskConfig() {
    cat ~/.bashrc | grep -icq "${BREW_UMASK}"
}

function hasBrewConfig() {
   hasBrewPathConfig && hasBrewUmaskConfig
}

function installBrew() {
    printf "${BLUE}[-] Installing brew...${NC}\n"
    setupBrewOS
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    export PATH="${BREW_PATH}:$PATH"
    eval "${BREW_UMASK}"
    brew install gcc
}

function configBrew() {
    setupBashrc

    printf "${BLUE}[-] Configuring brew...${NC}\n"

    if ! hasBrewPathConfig; then
        echo "export PATH='${BREW_PATH}'":'"$PATH"' >>~/.bashrc
    fi

    if ! hasBrewUmaskConfig; then
        echo "${BREW_UMASK}" >>~/.bashrc
    fi
}

function uninstallBrew() {
    if hasBrew; then
        printf "${BLUE}[-] Uninstall brew...${NC}\n"
        yes | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/uninstall)"
    fi
    test -e /home/linuxbrew/.linuxbrew/bin/brew && brew purge
    sed -i '/linuxbrew/d' ~/.bashrc
    sed -i "/${BREW_UMASK}/d" ~/.bashrc
    test -d /home/linuxbrew/.linuxbrew/bin && rm -R /home/linuxbrew/.linuxbrew/bin
    test -d /home/linuxbrew/.linuxbrew/lib && rm -R /home/linuxbrew/.linuxbrew/lib
    test -d /home/linuxbrew/.linuxbrew/share && rm -R /home/linuxbrew/.linuxbrew/share
}

function checkBrew() {
    if hasBrew && hasBrewConfig; then
        printf "${GREEN}[✔] brew${NC}\n"
    else
        printf "${RED}[x] brew${NC}\n"
    fi
}

function setupBrew() {
    if hasBrew && hasBrewConfig; then
        printf "${GREEN}[✔] Already brew${NC}\n"
        return
    fi

    if ! hasBrew && [[ "$OSTYPE" == "linux-gnu" ]]; then
        installBrew
    fi

    if ! hasBrewConfig; then
        configBrew
    fi
}

function purgeBrew() {
    if ! hasBrew; then
        return
    fi

    uninstallBrew
    purgeBrewOS
}
