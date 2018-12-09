#!/usr/bin/env bash

source "./src/constants.sh"

BASHRC_IMPORT="source ~/.bashrc"

function hasRuby() {
    which ruby | grep -icq "[^not found]"
}

function hasBashrc() {
    [[ -s ~/.bash_profile ]] && cat ~/.bash_profile | grep -icq BASHRC_IMPORT
}

function configureBashrc() {
    printf "\n${BLUE}[-] Configuring bashrc...${NC}\n"
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >> ~/.bash_profile
}

function tryConfigureBashrc() {
    if hasBashrc; then
        printf "\n${GREEN}[✔] Already bashrc${NC}\n"
        return
    fi
}

function endsWithNewLine() {
    test "$(tail -c 1 "$1" | wc -l)" -ne 0
}
