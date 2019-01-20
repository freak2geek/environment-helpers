#!/usr/bin/env bash

source "./src/constants.sh"

BASHRC_IMPORT="source ~/.bashrc"

function hasBashrc() {
    [[ -f ~/.bash_profile ]] && [[ "$(cat ~/.bash_profile | grep -ic "${BASHRC_IMPORT}")" -ne "0" ]]
}

function hasZshrc() {
    [[ -f ~/.zshrc ]]
}

function configBashrc() {
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >>~/.bash_profile
}

function setupBashrc() {
    if hasBashrc; then
        return
    fi

    configBashrc
}

function hasEnvrcInBash() {
    hasBashrc && [[ "$(cat ~/.bashrc | grep -ic "source ~/.envrc")" -ne "0" ]] &&
        [[ "$(cat ~/.bashrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function hasEnvrcInZsh() {
    hasZshrc && [[ "$(cat ~/.zshrc | grep -ic "source ~/.envrc")" -ne "0" ]] &&
        [[ "$(cat ~/.zshrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function hasEnvrc() {
    ! hasZshrc && hasEnvrcInBash || hasZshrc && hasEnvrcInBash && hasEnvrcInZsh
}

function configEnvrc() {
    printf "${BLUE}[-] Configuring .envrc...${NC}\n"

    if hasBashrc && ! hasEnvrcInBash; then
        setupBashrc

        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.bashrc
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.bashrc
    fi

    if hasZshrc && ! hasEnvrcInZsh; then
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.zshrc
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.zshrc
    fi
}

function setupEnvrc() {
    if hasEnvrc; then
        printf "${GREEN}[✔] Already .envrc${NC}\n"
        return
    fi

    configEnvrc
}

function checkEnvrc() {
    if hasEnvrc; then
        printf "${GREEN}[✔] .envrc${NC}\n"
    else
        printf "${RED}[x] .envrc${NC}\n"
    fi
}

function purgeEnvrc() {
    if ! hasEnvrc; then
        return
    fi

    printf "${BLUE}[-] Purging .envrc...${NC}\n"
    sedi "/envrc/d" ~/.bashrc
    sedi "/envrc/d" ~/.zshrc
}

function endsWithNewLine() {
    test "$(tail -c 1 "$1" | wc -l)" -ne 0
}

VISUDO_NOPASSWD="${USER} ALL=(ALL) NOPASSWD: ALL"

function hasSudoNoPasswd() {
    [[ $(sudo cat /etc/sudoers | grep -ic "${VISUDO_NOPASSWD}") -ne "0" ]]
}

function configSudoNoPasswd() {
    printf "${BLUE}[-] Configuring sudo nopasswd...${NC}\n"
    echo "${VISUDO_NOPASSWD}" | sudo EDITOR='tee -a' visudo
}

function checkSudoNoPasswd() {
    if hasSudoNoPasswd; then
        printf "${GREEN}[✔] sudo nopasswd${NC}\n"
    else
        printf "${RED}[x] sudo nopasswd${NC}\n"
    fi
}

function setupSudoNoPasswd() {
    if hasSudoNoPasswd; then
        printf "${GREEN}[✔] Already sudo nopasswd${NC}\n"
        return
    fi

    configSudoNoPasswd
}

function purgeSudoNoPasswd() {
    if ! hasSudoNoPasswd; then
        return
    fi
    printf "${BLUE}[-] Purging sudo nopasswd...${NC}\n"
    sudoSedi "/${VISUDO_NOPASSWD}/d" /etc/sudoers
}

function isOSX() {
    [[ "$OSTYPE" == "darwin"* ]]
}

function isLinux() {
    [[ "$OSTYPE" == "linux-gnu" ]]
}

function sedi() {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}

function sudoSedi() {
  sed --version >/dev/null 2>&1 && sudo sed -i -- "$@" || sudo sed -i "" "$@"
}
