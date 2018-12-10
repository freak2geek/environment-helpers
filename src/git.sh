#!/usr/bin/env bash

source "./src/constants.sh"

function hasGit() {
    which git | grep -icq "[^not found]"
}

function installGit() {
    printf "${BLUE}[-] Installing git...${NC}\n"
    brew install git
}

function uninstallGit() {
    printf "${BLUE}[-] Uninstalling git...${NC}\n"
    brew uninstall git
}

function checkGit() {
    if hasGit; then
        printf "${GREEN}[✔] git${NC}\n"
    else
        printf "${RED}[x] git${NC}\n"
    fi
}

function setupGit() {
    if hasGit; then
        printf "${GREEN}[✔] Already git${NC}\n"
        return
    fi

    installGit
}

function purgeGit() {
    if ! hasGit; then
        return
    fi

    uninstallGit
}
