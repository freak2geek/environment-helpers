#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"
source "./src/brew.sh"

# GIT FLOW default config
GITFLOW_BUGFIX="fix/"
GITFLOW_FEATURE="feature/"
GITFLOW_RELEASE="release/"
GITFLOW_HOTFIX="hotfix/"
GITFLOW_SUPPORT="support/"
GITFLOW_VERSIONTAG=""
GITFLOW_MASTER="master"
GITFLOW_DEVELOP="develop"

function hasGitFlow() {
    hasBrewByOS && [[ "$(brew ls git-flow 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function installGitFlow() {
    printf "${BLUE}[-] Installing git-flow...${NC}\n"
    brew install git-flow
}

function uninstallGitFlow() {
    printf "${BLUE}[-] Uninstalling git-flow...${NC}\n"
    brew uninstall git-flow
}

function hasGitConfig() {
    [[ -f ${PROJECT_PATH}/.git/config ]]
}

function hasGitFlowConfig() {
    hasGitConfig && cat ${PROJECT_PATH}/.git/config | grep -icq "\[gitflow \"prefix\"\]" && cat ${PROJECT_PATH}/.git/config | grep -icq "\[gitflow \"branch\"\]"
}

function purgeGitFlowConfig() {
    sedi '/\[gitflow \"prefix\"\]/d' ${PROJECT_PATH}/.git/config
    sedi '/bugfix =/d' ${PROJECT_PATH}/.git/config
    sedi '/feature =/d' ${PROJECT_PATH}/.git/config
    sedi '/release =/d' ${PROJECT_PATH}/.git/config
    sedi '/hotfix =/d' ${PROJECT_PATH}/.git/config
    sedi '/support =/d' ${PROJECT_PATH}/.git/config
    sedi '/versiontag =/d' ${PROJECT_PATH}/.git/config
    sedi '/\[gitflow \"branch\"\]/d' ${PROJECT_PATH}/.git/config
    sedi '/master =/d' ${PROJECT_PATH}/.git/config
    sedi '/develop =/d' ${PROJECT_PATH}/.git/config
}

function configGitFlow() {
    printf "${BLUE}[-] Configuring git-flow...${NC}\n"

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi

    tryPrintNewLine ${PROJECT_PATH}/.git/config

    printf "[gitflow \"prefix\"]" >>${PROJECT_PATH}/.git/config
    printf "\n\tbugfix = ${GITFLOW_BUGFIX}" >>${PROJECT_PATH}/.git/config
    printf "\n\tfeature = ${GITFLOW_FEATURE}" >>${PROJECT_PATH}/.git/config
    printf "\n\trelease = ${GITFLOW_RELEASE}" >>${PROJECT_PATH}/.git/config
    printf "\n\thotfix = ${GITFLOW_HOTFIX}" >>${PROJECT_PATH}/.git/config
    printf "\n\tsupport = ${GITFLOW_SUPPORT}" >>${PROJECT_PATH}/.git/config
    printf "\n\tversiontag = ${GITFLOW_VERSIONTAG}" >>${PROJECT_PATH}/.git/config
    printf "\n[gitflow \"branch\"]" >>${PROJECT_PATH}/.git/config
    printf "\n\tmaster = ${GITFLOW_MASTER}" >>${PROJECT_PATH}/.git/config
    printf "\n\tdevelop = ${GITFLOW_DEVELOP}" >>${PROJECT_PATH}/.git/config
}

function checkGitFlow() {
    if hasGitFlow && hasGitFlowConfig; then
        printf "${GREEN}[✔] git-flow${NC}\n"
    else
        printf "${RED}[x] git-flow${NC}\n"
    fi
}

function setupGitFlow() {
    if hasGitFlow && hasGitFlowConfig; then
        printf "${GREEN}[✔] Already git-flow${NC}\n"
        return
    fi

    if ! hasGitFlow; then
        installGitFlow
    fi

    if ! hasGitFlowConfig; then
        configGitFlow
    fi
}

function purgeGitFlow() {
    if hasGitFlow; then
        uninstallGitFlow
    fi

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi
}
