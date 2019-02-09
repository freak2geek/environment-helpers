#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorLerna() {
    hasMeteor && find ${METEOR_TOOL_DIR} -type d -name "lerna" | grep -icq "lerna"
}

function installMeteorLerna() {
    printf "${BLUE}[-] Installing meteor lerna...${NC}\n"
    meteor npm install lerna -g
}

function uninstallMeteorLerna() {
    printf "${BLUE}[-] Uninstalling meteor lerna...${NC}\n"
    meteor npm uninstall lerna -g
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

function setupProject() {
    printf "${BLUE}[-] Installing \"${PROJECT_NAME}\" project...${NC}\n"
    meteor lerna bootstrap $@
}
