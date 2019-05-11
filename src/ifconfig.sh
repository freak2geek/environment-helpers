#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasIfconfig() {
    which ifconfig >/dev/null && [[ "$(which ifconfig | grep -ic "not found")" -eq "0" ]]
}

function installIfconfig() {
    printf "${BLUE}[-] Installing ifconfig...${NC}\n"
    if isLinux; then
        sudo apt-get install --no-install-recommends net-tools -y
    fi
}

function checkIfconfig() {
    if hasIfconfig; then
        printf "${GREEN}[✔] ifconfig${NC}\n"
    else
        printf "${RED}[x] ifconfig${NC}\n"
    fi
}

function setupIfconfig() {
    if hasIfconfig; then
        printf "${GREEN}[✔] Already ifconfig${NC}\n"
        return
    fi

    installIfconfig
}

function getLocalIp() {
    if isOSX; then
        echo "$(ifconfig | grep '\<inet\>' | cut -d ' ' -f2 | grep -v '127.0.0.1' | head -n 1)"
        return
    elif isLinux; then
        echo "$(ifconfig | grep "inet" | awk '{print $2}' | cut -d/ -f1 | head -n 1)"
        return
    fi
}
