#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasGitFlow() {
    which git-flow >/dev/null && [[ $(which git-flow | grep -ic "not found") -eq "0" ]]
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

    bugfix=${1-'bugfix/'}
    feature=${2-'feature/'}
    release=${3-'release/'}
    hotfix=${4-'hotfix/'}
    support=${5-'support/'}
    versiontag=${6-''}
    master=${7-'master'}
    develop=${8-'development'}

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi

    if ! endsWithNewLine "./.git/config"; then
        printf "\n" >>./.git/config
    fi

    printf "[gitflow \"prefix\"]" >>./.git/config
    printf "\n\tbugfix = ${bugfix}" >>./.git/config
    printf "\n\tfeature = ${feature}" >>./.git/config
    printf "\n\trelease = ${release}" >>./.git/config
    printf "\n\tsupport = ${support}" >>./.git/config
    printf "\n\tversiontag = ${versiontag}" >>./.git/config
    printf "\n[gitflow \"branch\"]" >>./.git/config
    printf "\n\tmaster = ${master}" >>./.git/config
    printf "\n\tdevelop = ${develop}" >>./.git/config
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
        configGitFlow $@
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
