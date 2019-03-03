#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasRollup() {
    hasMeteor && hasLibForCurrentMeteor rollup
}

function installRollup() {
    installMeteorLib rollup
}

function uninstallRollup() {
    uninstallMeteorLib rollup
}

function checkRollup() {
    checkMeteorLib rollup
}

function setupRollup() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib rollup; then
        printf "${GREEN}[✔] Already meteor rollup${NC}\n"
        return
    fi

    if ! hasMeteorLib rollup; then
        installRollup
    fi
}

function purgeRollup() {
    if ! hasMeteorLib rollup; then
        return
    fi

    uninstallRollup
}
