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
    tryPrintNewLine ~/.bash_profile
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >>~/.bash_profile
}

function setupBashrc() {
    if hasBashrc; then
        return
    fi

    configBashrc
}

function purgeBashrc() {
    if ! hasBashrc; then
        return
    fi

    printf "${BLUE}[-] Purging .bashrc...${NC}\n"
    sedi "/[[ -s ~/.bashrc ]] &&/d" ~/.bash_profile
}

function hasGlobalEnvrcInBash() {
    [[ -f ~/.bashrc ]] && [[ "$(cat ~/.bashrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasGlobalEnvrcInZsh() {
    [[ -f ~/.zshrc ]] && [[ "$(cat ~/.zshrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalHomeAlias() {
    [[ -f ~/.envrc ]] && [[ "$(cat ~/.envrc | grep -ic "alias @${PROJECT_NAME}")" -ne "0" ]]
}

function getLocalHomeVarName() {
    localDirName="$(getNpmPackageName ${PROJECT_PATH}/package.json)"
    localDirName=$(echo ${localDirName} | sedr 's/\-/_/g')
    localDirName=$(echo ${localDirName} | sedr 's/@//g')
    localDirName=$(echo ${localDirName} | sedr 's/\//_/g')
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
    hasCurl && hasBashrc && hasLocalHome && hasLocalHomeAlias && hasGlobalEnvrcInBash && hasGlobalEnvrcInZsh && hasDynamicEnvrcLoader
}

function loadEnvrc() {
    [[ -s ~/.envrc ]] && source ~/.envrc
    [[ -s ./.envrc ]] && source ./.envrc
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
        printf "${GREEN}[✔] Set: local home${NC}\n"
    fi

    if ! hasLocalHomeAlias; then
        tryPrintNewLine ~/.envrc
        echo "alias @${PROJECT_NAME}=\"cd \${${localHomeName}}\"" >>~/.envrc
        eval "alias @${PROJECT_NAME}=\"cd \${${localHomeName}}\""
        printf "${GREEN}[✔] Set: local home alias${NC}\n"
    fi

    if ! hasGlobalEnvrcInBash; then
        tryPrintNewLine ~/.bashrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.bashrc
        loadEnvrc
        printf "${GREEN}[✔] Set: global .envrc in bash${NC}\n"
    fi

    if ! hasGlobalEnvrcInZsh; then
        tryPrintNewLine ~/.zshrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.zshrc
        loadEnvrc
        printf "${GREEN}[✔] Set: global .envrc in zsh${NC}\n"
    fi

    sedi "/.envrc-dl/d" ~/.envrc
    tryPrintNewLine ~/.envrc
    echo "[[ -s ~/.envrc-dl ]] && source ~/.envrc-dl" >>~/.envrc
    source ~/.envrc-dl
    printf "${GREEN}[✔] Set: dynamic .envrc loader${NC}\n"
}

function setupEnvrc() {
    if ! hasCurl; then
        setupCurl
    fi

    # ensure the dynamic loader is always updated to latest
    ENVRC_DYNAMIC_LOADER="$(curl -s https://raw.githubusercontent.com/freak2geek/environment-helpers/master/helpers/envrc-dynamic-loader.sh)"
    [[ -f ~/.envrc-dl ]] && rm ~/.envrc-dl
    echo "${ENVRC_DYNAMIC_LOADER}" >>~/.envrc-dl

    if hasEnvrc; then
        printf "${GREEN}[✔] Already .envrc${NC}\n"
        return
    fi

    OLD_PWD=${PWD}
    cd ${PROJECT_PATH}
    configEnvrc
    cd ${OLD_PWD}
}

function checkEnvrc() {
    OLD_PWD=${PWD}
    cd ${PROJECT_PATH}
    if hasEnvrc; then
        printf "${GREEN}[✔] .envrc${NC}\n"
    else
        printf "${RED}[x] .envrc${NC}\n"
    fi
    cd ${OLD_PWD}
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
    sedi "/alias @${PROJECT_NAME}/d" ~/.envrc
    sedi "/alias @old-pwd/d" ~/.envrc
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

function loadEnv {
  if [[ -f $1 ]] ; then
    while read -r line
    do
      [[ -z "$line" ]] && continue
      eval "export ${line}"
    done < "$1"
  fi
}

ENV_OVERRIDE_FILENAME=".env.override"

function setOverride() {
    override=${1-}
    unsetOverride ${override}
    tryPrintNewLine "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
    echo "${override}" >> "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}

function unsetOverride() {
    if [[ ! -f "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}" ]]; then
        return
    fi
    override=${1-}
    sedi "/${override}/d" "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}

function loadOverrides() {
    [[ -f "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}" ]] && loadEnv "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}

function cleanOverrides() {
    rm -f "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
    touch "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}
