#!/usr/bin/env bash

source "./src/constants.sh"

function hasGitFlow() {
    which git-flow | grep -icq "[^not found]"
}

function installGitFlow() {
    printf "\n${BLUE}[-] Installing git-flow...${NC}\n"
    brew install git-flow
}

function tryInstallGitFlow() {
    if hasGitFlow; then
        printf "\n${GREEN}[✔] Already git-flow${NC}\n"
        return
    fi

    installGitFlow
}

function uninstallGitFlow() {
    printf "\n${BLUE}[-] Uninstalling git-flow...${NC}\n"
    brew uninstall git-flow
}

function tryUninstallGitFlow() {
    if ! hasGitFlow; then
        return
    fi

    uninstallGitFlow
}


