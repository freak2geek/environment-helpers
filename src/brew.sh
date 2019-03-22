#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"
source "./src/ruby.sh"

BREW_PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:~/.linuxbrew/bin:~/.linuxbrew/sbin"
BREW_UMASK="umask 002"

BREW_OS_DEPENDENCIES="build-essential curl g++ file git m4 texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev gawk make patch tcl"

function setupBrewOS() {
    sudo apt-get update -y &&
        sudo apt-get update --fix-missing -y &&
        sudo apt-get install --no-install-recommends ${BREW_OS_DEPENDENCIES} -y &&
        sudo apt autoremove -y
}

function purgeBrewOS() {
    sudo apt-get remove --purge ${BREW_OS_DEPENDENCIES} -y &&
        sudo apt autoremove -y
}

function hasLinuxBrew() {
    [[ "$(brew --version 2>&1 | grep -ic "not")" -eq "0" ]]
}

function hasOsxBrew() {
    which brew >/dev/null && [[ "$(which brew | grep -ic "not found")" -eq "0" ]]
}

function hasBrewPathConfig() {
    hasEnvrc && cat ~/.envrc | grep -icq "${BREW_PATH}"
}

function hasBrewUmaskConfig() {
    hasEnvrc && cat ~/.envrc | grep -icq "${BREW_UMASK}"
}

function hasBrewConfig() {
   hasBrewPathConfig && hasBrewUmaskConfig
}

function hasBrewByOS() {
    (isLinux && hasCurl && hasLinuxBrew && hasBrewConfig) || (isOSX && hasCurl && hasOsxBrew)
}

function installBrewInLinux() {
    if ! hasCurl; then
        setupCurl
    fi

    printf "${BLUE}[-] Installing brew...${NC}\n"
    setupBrewOS
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    export PATH="${BREW_PATH}:$PATH"
    eval "${BREW_UMASK}"
    brew install gcc
}

function installBrewInOSX() {
    printf "${BLUE}[-] Installing brew...${NC}\n"
    yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function configBrewInLinux() {
    configEnvrc

    printf "${BLUE}[-] Configuring brew...${NC}\n"

    if ! hasBrewPathConfig; then
        tryPrintNewLine ~/.envrc
        echo "export PATH='${BREW_PATH}'":'"$PATH"' >>~/.envrc
    fi

    if ! hasBrewUmaskConfig; then
        tryPrintNewLine ~/.envrc
        echo "${BREW_UMASK}" >>~/.envrc
    fi
}

function uninstallBrewInLinux() {
    if isOSX; then
        return
    fi

    if hasBrewByOS; then
        if ! hasCurl; then
            setupCurl
        fi
        brew install ruby
        printf "${BLUE}[-] Uninstall brew...${NC}\n"
        yes | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/uninstall)"
    fi
    test -e /home/linuxbrew/.linuxbrew/bin/brew && brew purge
    sedi '/linuxbrew/d' ~/.envrc
    sedi "/${BREW_UMASK}/d" ~/.envrc
    test -d /home/linuxbrew/.linuxbrew/bin && rm -R /home/linuxbrew/.linuxbrew/bin
    test -d /home/linuxbrew/.linuxbrew/lib && rm -R /home/linuxbrew/.linuxbrew/lib
    test -d /home/linuxbrew/.linuxbrew/share && rm -R /home/linuxbrew/.linuxbrew/share
}

function uninstallBrewInOSX() {
    printf "${BLUE}[-] Uninstall brew...${NC}\n"
    yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
}

function checkBrew() {
    if hasBrewByOS; then
        printf "${GREEN}[✔] brew${NC}\n"
    else
        printf "${RED}[x] brew${NC}\n"
    fi
}

function setupBrew() {
    if hasBrewByOS; then
        printf "${GREEN}[✔] Already brew${NC}\n"
        return
    fi

    if ! hasBrewByOS; then
        if isLinux; then
            installBrewInLinux
        elif isOSX; then
            installBrewInOSX
        fi
    fi

    if ! hasBrewConfig; then
        if isLinux; then
            configBrewInLinux
        fi
    fi
}

function purgeBrew() {
    if ! hasBrewByOS; then
        return
    fi

    if isLinux; then
        uninstallBrewInLinux
        purgeBrewOS
    elif isOSX; then
        uninstallBrewInOSX
    fi
}
