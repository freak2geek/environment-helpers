#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorLerna() {
    hasMeteor && hasLibForCurrentMeteor lerna
}

function installMeteorLerna() {
    installMeteorLib lerna
}

function uninstallMeteorLerna() {
    uninstallMeteorLib lerna
}

function checkMeteorLerna() {
    checkMeteorLib lerna
}

function setupMeteorLerna() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLerna; then
        printf "${GREEN}[✔] Already meteor lerna${NC}\n"
        return
    fi

    if ! hasMeteorLerna; then
        installMeteorLerna
    fi
}

function purgeMeteorLerna() {
    if ! hasMeteorLerna; then
        return
    fi

    uninstallMeteorLerna
}

function setupLernaProject() {
    printf "${BLUE}[-] Installing \"${PROJECT_NAME}\" project...${NC}\n"
    meteor lerna bootstrap $@
}

function cleanLernaProject() {
    printf "${BLUE}[-] Cleaning \"${PROJECT_NAME}\" project...${NC}\n"
    rm -rf ./node_modules
}
