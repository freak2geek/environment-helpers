#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

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
    printf "${PURPLE} - Env Path: ${meteorEnvPath}${NC}\n"
    loadEnv ${meteorEnvPath}
}

function startMeteorApp() {
    printf "${BLUE}[-] Starting \"${APP_TO}\" app...${NC}\n"
    printf "${PURPLE} - Env: ${ENV_TO}${NC}\n"

    loadMeteorEnv

    printf "${PURPLE} - Env Override: ${ENV_OVERRIDE}${NC}\n"
    eval ${ENV_OVERRIDE}

    cd ./${APPS_PATH}/${APP_TO}
    meteorSettingsPath=./${APP_CONFIG_PATH}/${ENV_TO}/settings.json
    printf "${PURPLE} - Settings Path: ${meteorSettingsPath}${NC}\n"
    printf "${PURPLE} - Port: ${PORT}${NC}\n"
    meteor run --settings ${meteorSettingsPath} --port ${PORT} $@
}

function killMeteorApp() {
    printf "${BLUE}[-] Killing \"${APP_TO}\" app...${NC}\n"
    printf "${PURPLE} - Port: ${PORT}${NC}\n"

    loadMeteorEnv

    killProcessByPort ${PORT}
}
