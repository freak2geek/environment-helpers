#!/usr/bin/env bash

source "./src/constants.sh"

BASHRC_IMPORT="source ~/.bashrc"
ENVRC_DYNAMIC_LOADER="$(cat ./helpers/envrc-dynamic-loader.sh)"

function hasBashrc() {
    [[ -f ~/.bash_profile ]] && [[ "$(cat ~/.bash_profile | grep -ic "${BASHRC_IMPORT}")" -ne "0" ]]
}

function hasZshrc() {
    [[ -f ~/.zshrc ]]
}

function configBashrc() {
    tryPrintNewLine ~/.bash_profile
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >>~/.bash_profile
}

function setupBashrc() {
    if hasBashrc; then
        return
    fi

    configBashrc
}

function hasGlobalEnvrcInBash() {
    [[ -f ~/.bashrc ]] && [[ "$(cat ~/.bashrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalEnvrcInBash() {
    [[ -f ~/.bashrc ]] && [[ "$(cat ~/.bashrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function hasGlobalEnvrcInZsh() {
    [[ -f ~/.zshrc ]] && [[ "$(cat ~/.zshrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalEnvrcInZsh() {
    [[ -f ~/.zshrc ]] && [[ "$(cat ~/.zshrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function getLocalHomeVarName() {
    localDirName=${PWD##*/}
    localDirName=$(echo ${localDirName} | sedr 's/\-/_/g')
    localHomeName=$(echo ${localDirName} | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/')
    echo "${localHomeName}_HOME"
}

function hasLocalHome() {
    localHomeName="$(getLocalHomeVarName)"
    [[ -f ~/.envrc ]] && [[ "$(cat ~/.envrc | grep -ic "export ${localHomeName}=${PWD}")" -ne "0" ]]
}

function hasDynamicEnvrcLoader() {
    [[ -f ~/.envrc ]] && [[ "$(cat ~/.envrc | grep -ic "source ~/.envrc-dl")" -ne "0" ]]
}

function hasEnvrc() {
    hasBashrc && hasLocalHome && hasGlobalEnvrcInBash && hasGlobalEnvrcInZsh && hasLocalEnvrcInBash &&
        hasLocalEnvrcInZsh && hasDynamicEnvrcLoader
}

function configEnvrc() {
    printf "${BLUE}[-] Configuring .envrc...${NC}\n"

    if ! hasBashrc; then
        setupBashrc
    fi

    if ! hasLocalHome; then
        tryPrintNewLine ~/.envrc
        localHomeName="$(getLocalHomeVarName)"
        echo "export ${localHomeName}=${PWD}" >>~/.envrc
        export ${localHomeName}=${PWD}
        printf "${GREEN}[✔] local home${NC}\n"
    fi

    if ! hasGlobalEnvrcInBash || ! hasGlobalEnvrcInZsh; then
        tryPrintNewLine ~/.envrc
        [[ -s ~/.envrc ]] && source ~/.envrc
    fi

    if ! hasLocalEnvrcInBash || ! hasLocalEnvrcInZsh; then
        tryPrintNewLine ~/.envrc
        [[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc
    fi

    if ! hasGlobalEnvrcInBash; then
        tryPrintNewLine ~/.bashrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.bashrc
        printf "${GREEN}[✔] global .envrc in bash${NC}\n"
    fi

    if ! hasLocalEnvrcInBash; then
        tryPrintNewLine ~/.bashrc
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.bashrc
        printf "${GREEN}[✔] local .envrc in bash${NC}\n"
    fi

    if ! hasGlobalEnvrcInZsh; then
        tryPrintNewLine ~/.zshrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.zshrc
        printf "${GREEN}[✔] global .envrc in zsh${NC}\n"
    fi

    if ! hasLocalEnvrcInZsh; then
        tryPrintNewLine ~/.zshrc
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.zshrc
        printf "${GREEN}[✔] local .envrc in zsh${NC}\n"
    fi

    if ! hasDynamicEnvrcLoader; then
        tryPrintNewLine ~/.envrc
        echo "[[ -s ~/.envrc-dl ]] && source ~/.envrc-dl" >>~/.envrc
        printf "${GREEN}[✔] dynamic .envrc loader${NC}\n"
    fi
}

function setupEnvrc() {
    # ensure the dynamic loader is always updated to latest
    rm ~/.envrc-dl
    echo "${ENVRC_DYNAMIC_LOADER}" >>~/.envrc-dl

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
    localHomeName="$(getLocalHomeVarName)"

    printf "${BLUE}[-] Purging .envrc...${NC}\n"
    sedi "/envrc/d" ~/.bashrc
    sedi "/envrc/d" ~/.zshrc
    sedi "/export ${localHomeName}/d" ~/.envrc
}

function endsWithNewLine() {
    [[ -f $1 ]] && test "$(tail -c 1 "$1" | wc -l)" -ne 0
}

function tryPrintNewLine() {
    fileToPrint=${1-}
    if ! endsWithNewLine ${fileToPrint}; then
        printf "\n" >> ${fileToPrint}
    fi
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

function sedr() {
    if isOSX; then
        sed -E -- "$@"
    else
        sed -r -- "$@"
    fi
}

function sudoSedi() {
    sed --version >/dev/null 2>&1 && sudo sed -i -- "$@" || sudo sed -i "" "$@"
}

function killProcessByPort() {
    portToKill=${1-''}
    portPid="$(pgrep -f ${portToKill})"

    if [[ ${portPid} -eq '' ]]; then
        return
    fi

    sudo kill -9 ${portPid}
}
