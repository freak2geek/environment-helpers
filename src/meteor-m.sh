#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorM() {
    meteor npm ls --depth 0 -g 2>/dev/null | grep -icq " m@"
}

function installMeteorM() {
    printf "${BLUE}[-] Installing meteor m...${NC}\n"
    meteor npm install m -g
}

function uninstallMeteorM() {
    printf "${BLUE}[-] Uninstalling meteor m...${NC}\n"
    meteor npm uninstall m -g
}

function configureMeteorM() {
    printf "${BLUE}[-] Configuring meteor m...${NC}\n"
    sudo chmod -R 777 /usr/local
}

function checkMeteorM() {
    if hasMeteorM; then
        printf "${GREEN}[✔] meteor m${NC}\n"
    else
        printf "${RED}[x] meteor m${NC}\n"
    fi
}

function setupMeteorM() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorM; then
        printf "${GREEN}[✔] Already meteor m${NC}\n"
        return
    fi

    installMeteorM
    configureMeteorM
}

function purgeMeteorM() {
    if ! hasMeteorM; then
        return
    fi

    uninstallMeteorM
}

function hasMongo() {
    version=${1-'stable'}
    meteor m | grep -icq "ο.*${version}"
}

function installMongo() {
    version=${1-'stable'}
    if hasMongo $@; then
        printf "${GREEN}[✔] Already mongo@${version}${NC}\n"
        return;
    fi
    printf "${BLUE}[-] Installing mongo@${version}...${NC}\n"
    yes | meteor m ${version}
}

function uninstallMongo() {
    version=${1-'stable'}
    printf "${BLUE}[-] Uninstalling mongo@${version}...${NC}\n"
    yes | meteor m rm ${version}
}

function hasMongoConfig() {
    dbpath=${2-'/data/db'}
    [[ -d  ${dbpath} ]] && ls -la /data/db | grep -icq "drwxrwxrwx .* \."
}

function configMongo() {
    dbpath=${2-'/data/db'}
    if hasMongoConfig $@; then
        printf "${GREEN}[✔] Already dbpath \"${dbpath}\"${NC}\n"
        return
    fi

    printf "${BLUE}[-] Configuring dbpath \"${dbpath}\"...${NC}\n"
    sudo mkdir -p ${dbpath}
    sudo chmod -R 777 ${dbpath}
}

function setupMongo() {
    setupMeteorM
    configMongo $@
    installMongo $@
}

function purgeMongo() {
    uninstallMongo $@
}
