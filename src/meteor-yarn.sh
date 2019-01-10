#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorYarn() {
    hasMeteor && meteor npm ls --depth 0 -g 2>/dev/null | grep -icq "yarn@"
}

function installMeteorYarn() {
    printf "${BLUE}[-] Installing meteor yarn...${NC}\n"
    sudo chmod -R 777 ~/.npm
    meteor npm install yarn -g
}

function uninstallMeteorYarn() {
    printf "${BLUE}[-] Uninstalling meteor yarn...${NC}\n"
    meteor npm uninstall yarn -g
}

function hasMeteorYarnConfig() {
    [[ -d ~/.cache ]] && ls -la ~ | grep -icq "drwxrwxrwx .* \.cache"
}

function configMeteorYarn() {
    printf "${BLUE}[-] Configuring meteor yarn...${NC}\n"
    [[ ! -d ~/.cache ]] && mkdir ~/.cache
    sudo chmod 777 ~/.cache
}

function checkMeteorYarn() {
    if hasMeteorYarn && hasMeteorYarnConfig; then
        printf "${GREEN}[✔] meteor yarn${NC}\n"
    else
        printf "${RED}[x] meteor yarn${NC}\n"
    fi
}

function setupMeteorYarn() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorYarn && hasMeteorYarnConfig; then
        printf "${GREEN}[✔] Already meteor yarn${NC}\n"
        return
    fi

    if ! hasMeteorYarn; then
        installMeteorYarn
    fi

    if ! hasMeteorYarnConfig; then
        configMeteorYarn
    fi
}

function purgeMeteorYarn() {
    if ! hasMeteorYarn; then
        return
    fi

    uninstallMeteorYarn
    rm -rf ~/.cache
}

function getPackageName() {
    path=${1-"."}
    cd ${path}
    cat package.json | sed 's/.*"name": "\(.*\)".*/\1/;t;d'
}

function hasYarnDeps() {
    path=${1-"."}
    cd ${path}
    hasMeteorYarn && [[ $(meteor yarn check --verify-tree 2>&1 >/dev/null | grep -ic "error") -eq "0" ]]
}

function checkYarnDeps() {
    oldPath=${PWD}
    path=${1-"."}
    package=${2-$(getPackageName $@)}

    if hasYarnDeps $@; then
        printf "${GREEN}[✔] \"${package}\" dependencies${NC}\n"
    else
        printf "${RED}[x] \"${package}\" dependencies${NC}\n"
    fi

    cd ${oldPath}
}

function installYarnDeps() {
    oldPath=${PWD}
    path=${1-"."}
    package=${2-$(getPackageName $@)}

    printf "${BLUE}[-] Installing \"${package}\" dependencies...${NC}\n"
    cd ${path}
    meteor yarn install
    cd ${oldPath}
}

function setupYarnDeps() {
    oldPath=${PWD}
    path=${1-"."}
    package=${2-$(getPackageName $@)}

    if hasYarnDeps $@; then
        printf "${GREEN}[✔] Already \"${package}\" dependencies${NC}\n"
        return
    fi

    installYarnDeps $@
}
