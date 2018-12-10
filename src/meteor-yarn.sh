#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorYarn() {
    meteor npm ls --depth 0 -g 2>/dev/null | grep -icq "yarn@"
}

function installMeteorYarn() {
    printf "${BLUE}[-] Installing meteor yarn...${NC}\n"
    meteor npm install yarn -g
}

function uninstallMeteorYarn() {
    printf "${BLUE}[-] Uninstalling meteor yarn...${NC}\n"
    meteor npm uninstall yarn -g
}

function checkMeteorYarn() {
    if hasMeteorYarn; then
        printf "${GREEN}[✔] meteor yarn${NC}\n"
    else
        printf "${RED}[x] meteor yarn${NC}\n"
    fi
}

function setupMeteorYarn() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorYarn; then
        printf "${GREEN}[✔] Already meteor yarn${NC}\n"
        return
    fi

    installMeteorYarn
}

function purgeMeteorYarn() {
    if ! hasMeteorYarn; then
        return
    fi

    uninstallMeteorYarn
}
