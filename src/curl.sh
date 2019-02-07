#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasCurl() {
    which curl >/dev/null && [[ "$(which git-flow | grep -ic "not found")" -eq "0" ]]
}

function installCurl() {
    printf "${BLUE}[-] Installing curl...${NC}\n"
    if isOSX; then
        brew install curl
    else
        sudo apt-get install --no-install-recommends curl -y
    fi
}

function uninstallCurl() {
    printf "${BLUE}[-] Uninstalling curl...${NC}\n"
    if isOSX; then
        brew uninstall curl
    else
        sudo apt-get remove --purge curl -y
    fi
}

function checkCurl() {
    if hasCurl; then
        printf "${GREEN}[✔] curl${NC}\n"
    else
        printf "${RED}[x] curl${NC}\n"
    fi
}

function setupCurl() {
    if hasCurl; then
        printf "${GREEN}[✔] Already curl${NC}\n"
        return
    fi

    installCurl
}

function purgeCurl() {
    if hasCurl; then
        uninstallCurl
    fi
}
