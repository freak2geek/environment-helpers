#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorConcurrently() {
    hasMeteor && hasLibForCurrentMeteor concurrently
}

function installMeteorConcurrently() {
    installMeteorLib concurrently
}

function uninstallMeteorConcurrently() {
    uninstallMeteorLib concurrently
}

function checkMeteorConcurrently() {
    checkMeteorLib concurrently
}

function setupMeteorConcurrently() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib concurrently; then
        printf "${GREEN}[✔] Already meteor concurrently${NC}\n"
        return
    fi

    if ! hasMeteorLib concurrently; then
        installMeteorConcurrently
    fi
}

function purgeMeteorConcurrently() {
    if ! hasMeteorLib concurrently; then
        return
    fi

    uninstallMeteorConcurrently
}
