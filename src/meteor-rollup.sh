#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

function hasMeteorRollup() {
    hasMeteor && hasLibForCurrentMeteor rollup
}

function installMeteorRollup() {
    installMeteorLib rollup
}

function uninstallMeteorRollup() {
    uninstallMeteorLib rollup
}

function checkMeteorRollup() {
    checkMeteorLib rollup
}

function setupMeteorRollup() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib rollup; then
        printf "${GREEN}[✔] Already meteor rollup${NC}\n"
        return
    fi

    if ! hasMeteorLib rollup; then
        installMeteorRollup
    fi
}

function purgeMeteorRollup() {
    if ! hasMeteorLib rollup; then
        return
    fi

    uninstallMeteorRollup
}
