#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

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
    which git-flow >/dev/null && [[ "$(which git-flow | grep -ic "not found")" -eq "0" ]]
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
    [[ -f ./.git/config ]]
}

function hasGitFlowConfig() {
    hasGitConfig && cat ./.git/config | grep -icq "\[gitflow \"prefix\"\]" && cat ./.git/config | grep -icq "\[gitflow \"branch\"\]"
}

function purgeGitFlowConfig() {
    sedi '/\[gitflow \"prefix\"\]/d' ./.git/config
    sedi '/bugfix =/d' ./.git/config
    sedi '/feature =/d' ./.git/config
    sedi '/release =/d' ./.git/config
    sedi '/hotfix =/d' ./.git/config
    sedi '/support =/d' ./.git/config
    sedi '/versiontag =/d' ./.git/config
    sedi '/\[gitflow \"branch\"\]/d' ./.git/config
    sedi '/master =/d' ./.git/config
    sedi '/develop =/d' ./.git/config
}

function configGitFlow() {
    printf "${BLUE}[-] Configuring git-flow...${NC}\n"

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi

    tryPrintNewLine ./.git/config

    printf "[gitflow \"prefix\"]" >>./.git/config
    printf "\n\tbugfix = ${GITFLOW_BUGFIX}" >>./.git/config
    printf "\n\tfeature = ${GITFLOW_FEATURE}" >>./.git/config
    printf "\n\trelease = ${GITFLOW_RELEASE}" >>./.git/config
    printf "\n\thotfix = ${GITFLOW_HOTFIX}" >>./.git/config
    printf "\n\tsupport = ${GITFLOW_SUPPORT}" >>./.git/config
    printf "\n\tversiontag = ${GITFLOW_VERSIONTAG}" >>./.git/config
    printf "\n[gitflow \"branch\"]" >>./.git/config
    printf "\n\tmaster = ${GITFLOW_MASTER}" >>./.git/config
    printf "\n\tdevelop = ${GITFLOW_DEVELOP}" >>./.git/config
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
