#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorLerna() {
    hasMeteor && checkMeteorLib lerna
}

function installMeteorLerna() {
    printf "${BLUE}[-] Installing meteor lerna...${NC}\n"
    installMeteorLib lerna
}

function uninstallMeteorLerna() {
    printf "${BLUE}[-] Uninstalling meteor lerna...${NC}\n"
    uninstallMeteorLib lerna
}

function checkMeteorLerna() {
    if hasMeteorLerna; then
        printf "${GREEN}[✔] meteor lerna${NC}\n"
    else
        printf "${RED}[x] meteor lerna${NC}\n"
    fi
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
