#!/usr/bin/env bash

source "./src/constants.sh"

function hasMeteor() {
    which meteor >/dev/null && [[ "$(which meteor | grep -ic "not found")" -eq "0" ]]
}

function installMeteor() {
    printf "${BLUE}[-] Installing meteor...${NC}\n"
    curl https://install.meteor.com/ | sh
}

function uninstallMeteor() {
    printf "${BLUE}[-] Uninstalling meteor...${NC}\n"
    sudo rm /usr/local/bin/meteor
    rm -rf ~/.meteor
}

function checkMeteor() {
    if hasMeteor; then
        printf "${GREEN}[✔] meteor${NC}\n"
    else
        printf "${RED}[x] meteor${NC}\n"
    fi
}

function setupMeteor() {
    if hasMeteor; then
        printf "${GREEN}[✔] Already meteor${NC}\n"
        return
    fi

    installMeteor
}

function purgeMeteor() {
    if ! hasMeteor; then
        return
    fi

    uninstallMeteor
}

APPS_PATH='.'
APP_CONFIG_PATH='private/config'

PORT=3000
APP_TO=''
ENV_TO=''
ENV_OVERRIDE=''

function loadMeteorEnv() {
    meteorEnvPath=./${APPS_PATH}/${APP_TO}/${APP_CONFIG_PATH}/${ENV_TO}/.env
    echo ${meteorEnvPath}
    loadEnv ${meteorEnvPath}
}

function startMeteorApp() {
    printf "${BLUE}[-] Starting \"${APP_TO}\" app...${NC}\n"

    loadMeteorEnv
    eval ${ENV_OVERRIDE}

    cd ./${APPS_PATH}/${APP_TO}
    meteor run --settings ./${APP_CONFIG_PATH}/${ENV_TO}/settings.json --port ${PORT} $@
}

function killMeteorApp() {
    printf "${BLUE}[-] Killing \"${APP_TO}\"...${NC}\n"

    loadMeteorEnv

    killProcessByPort ${PORT}
}
