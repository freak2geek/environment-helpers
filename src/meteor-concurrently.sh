#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasConcurrently() {
    hasMeteor && hasLibForCurrentMeteor concurrently
}

function installConcurrently() {
    installMeteorLib concurrently
}

function uninstallConcurrently() {
    uninstallMeteorLib concurrently
}

function checkConcurrently() {
    checkMeteorLib concurrently
}

function setupConcurrently() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib concurrently; then
        printf "${GREEN}[✔] Already meteor concurrently${NC}\n"
        return
    fi

    if ! hasMeteorLib concurrently; then
        installConcurrently
    fi
}

function purgeConcurrently() {
    if ! hasMeteorLib concurrently; then
        return
    fi

    uninstallConcurrently
}
