#!/usr/bin/env bash

source "./src/constants.sh"

BASHRC_IMPORT="source ~/.bashrc"

function hasBashrc() {
    [[ -f ~/.bash_profile ]] && [[ $(cat ~/.bash_profile | grep -ic "${BASHRC_IMPORT}") -ne "0" ]]
}

function configBashrc() {
    printf "${BLUE}[-] Configuring bashrc...${NC}\n"
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >> ~/.bash_profile
}

function setupBashrc() {
    if hasBashrc; then
        printf "${GREEN}[✔] Already bashrc${NC}\n"
        return
    fi

    configBashrc
}

function endsWithNewLine() {
    test "$(tail -c 1 "$1" | wc -l)" -ne 0
}
