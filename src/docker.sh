#!/usr/bin/env bash

source "./src/constants.sh"

function hasDocker() {
    which docker >/dev/null && [[ "$(which docker | grep -ic "not found")" -eq "0" ]]
}

function installDocker() {
    printf "${BLUE}[-] Installing docker...${NC}\n"
    brew install docker
}

function uninstallDocker() {
    printf "${BLUE}[-] Uninstalling docker...${NC}\n"
    brew uninstall docker
}

function checkDocker() {
    if hasDocker; then
        printf "${GREEN}[✔] docker${NC}\n"
    else
        printf "${RED}[x] docker${NC}\n"
    fi
}

function setupDocker() {
    if hasDocker; then
        printf "${GREEN}[✔] Already docker${NC}\n"
        return
    fi

    installDocker
}

function purgeDocker() {
    if ! hasDocker; then
        return
    fi

    uninstallDocker
}
