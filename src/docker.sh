#!/usr/bin/env bash

source "./src/constants.sh"

function hasDockerInMac() {
    [[ "$(brew cask list 2>&1 | grep -ic "docker")" -ne "0" ]]
}

function hasDockerInLinux() {
    [[ "$(snap list docker 2>&1 | grep -ic "no matching snaps")" -eq "0" ]]
}

function installDockerInMac() {
    printf "${BLUE}[-] Installing docker...${NC}\n"
    brew cask install docker
}

function installDockerInLinux() {
    printf "${BLUE}[-] Installing docker...${NC}\n"
    yes | sudo snap install docker
}

function uninstallDockerInMac() {
    printf "${BLUE}[-] Uninstalling docker...${NC}\n"
    brew cask uninstall docker
}

function uninstallDockerInLinux() {
    printf "${BLUE}[-] Uninstalling docker...${NC}\n"
    yes | sudo snap remove docker
}

function checkDocker() {
    if isOSX && hasDockerInMac; then
        printf "${GREEN}[✔] docker${NC}\n"
    elif isLinux && hasDockerInLinux; then
        printf "${GREEN}[✔] docker${NC}\n"
    else
        printf "${RED}[x] docker${NC}\n"
    fi
}

function setupDocker() {
    if isOSX && hasDockerInMac; then
        printf "${GREEN}[✔] Already docker${NC}\n"
        return
    elif isLinux && hasDockerInLinux; then
        printf "${GREEN}[✔] Already docker${NC}\n"
        return
    fi

    printf "${BLUE}[-] Setting up docker...${NC}\n"

    if isOSX && ! hasDockerInMac; then
        installDockerInMac
    elif isLinux && ! hasDockerInLinux; then
        installDockerInLinux
    fi
}

function purgeDocker() {
    if isOSX && ! hasDockerInMac; then
        return
    elif isLinux && ! hasDockerInLinux; then
        return
    fi

    printf "${BLUE}[-] Purging docker...${NC}\n"

    if isOSX; then
        uninstallDockerInMac
    elif isLinux; then
        uninstallDockerInLinux
    fi
}

function isRunningDocker() {
    [[ "$(docker stats --no-stream 2>&1 | grep -ic "Cannot connect to the Docker daemon")" -eq "0" ]]
}

function waitDocker() {
    while ! isRunningDocker; do sleep 1; done
}

function startDockerInMac() {
    open --background /Applications/Docker.app
}

function startDockerInLinux() {
    snap run docker
}

function startDocker() {
    if isRunningDocker; then
        printf "${GREEN}[✔] Already running docker${NC}\n"
        return
    fi

    printf "${BLUE}[-] Starting docker...${NC}\n"
    if isOSX; then
        startDockerInMac
    elif isLinux; then
        startDockerInLinux
    fi
}

function killDocker() {
    if ! isRunningDocker; then
        return
    fi

    printf "${BLUE}[-] Killing docker...${NC}\n"
    sudo pkill docker
}
