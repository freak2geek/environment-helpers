#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

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

function hasGitConfig() {
    [[ -f ./.git/config ]]
}

function hasGitFlowPrefix() {
    hasGitConfig && cat ./.git/config | grep -icq "[gitflow \"prefix\"]"
}

function removeGitFlowConfig() {
    sed -i '/\[gitflow \"prefix\"\]/d' ./.git/config
    sed -i '/bugfix =/d' ./.git/config
    sed -i '/feature =/d' ./.git/config
    sed -i '/release =/d' ./.git/config
    sed -i '/hotfix =/d' ./.git/config
    sed -i '/support =/d' ./.git/config
    sed -i '/versiontag =/d' ./.git/config
    sed -i '/\[gitflow \"branch\"\]/d' ./.git/config
    sed -i '/master =/d' ./.git/config
    sed -i '/develop =/d' ./.git/config
}

function configureGitFlow() {
    printf "\n${BLUE}[-] Configuring git-flow...${NC}\n"

    bugfix=${1-'bugfix/'}
    feature=${2-'feature/'}
    release=${3-'release/'}
    hotfix=${4-'hotfix/'}
    support=${5-'support/'}
    versiontag=${6-''}
    master=${7-'master'}
    develop=${8-'development'}

    if hasGitFlowPrefix; then
        removeGitFlowConfig
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
