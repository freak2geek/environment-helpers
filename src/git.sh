#!/usr/bin/env bash

source "./src/constants.sh"

function hasGit() {
    which git | grep -icq "[^not found]"
}

function installGit() {
    printf "\n${BLUE}[-] Installing git...${NC}\n"
    brew install git
}

function tryInstallGit() {
    if hasGit; then
        printf "\n${GREEN}[✔] Already git${NC}\n"
        return
    fi

    installGit
}

function uninstallGit() {
    printf "\n${BLUE}[-] Uninstalling git...${NC}\n"
    brew uninstall git
}

function tryUninstallGit() {
    if ! hasGit; then
        return
    fi

    uninstallGit
}
