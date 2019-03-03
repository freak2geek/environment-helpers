#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

METEOR_TOOL_DIR=~/.meteor/packages/meteor-tool

function hasMeteor() {
    hasCurl && which meteor >/dev/null && [[ "$(which meteor | grep -ic "not found")" -eq "0" ]]
}

function installMeteor() {
    if ! hasCurl; then
        setupCurl
    fi

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

function hasLibForCurrentMeteor() {
    libToInstall=${1-''}
    [[ "$(meteor ${libToInstall} --help 2>&1 | grep -ic "is not a Meteor command")" -eq "0" ]]
}

function hasMeteorLib() {
    libToInstall=${1-''}
    meteorCounts="$(find ${METEOR_TOOL_DIR} -maxdepth 3 -type f -name "meteor" | wc -l | tr -d '[:space:]')"
    libCounts="$(find ${METEOR_TOOL_DIR} -maxdepth 5 -type l -name ${libToInstall} | wc -l | tr -d '[:space:]')"
    [[ ${meteorCounts} -eq ${libCounts} ]]
}

function installMeteorLib() {
    libToInstall=${1-''}

    printf "${BLUE}[-] Installing meteor ${libToInstall}...${NC}\n"

    for meteor in `find ${METEOR_TOOL_DIR} -maxdepth 3 -type f -name "meteor"`
    do
        libCount="$(find "$(dirname ${meteor})" -maxdepth 3 -type l -name ${libToInstall} | wc -l | tr -d '[:space:]')"
        if [[ ${libCount} -eq "0" ]]; then
            eval "${meteor} npm install -g ${libToInstall}"
        fi
    done
}

function uninstallMeteorLib() {
    libToInstall=${1-''}

    printf "${BLUE}[-] Uninstalling meteor ${libToInstall}...${NC}\n"

    for meteor in `find ${METEOR_TOOL_DIR} -maxdepth 3 -type f -name "meteor"`
    do
        eval "${meteor} npm uninstall -g ${libToInstall}"
    done

}

function checkMeteorLib() {
    libToInstall=${1-''}

    if hasMeteor && hasMeteorLib $@ && hasLibForCurrentMeteor $@; then
        printf "${GREEN}[✔] meteor ${libToInstall}${NC}\n"
    elif hasMeteor && hasLibForCurrentMeteor $@; then
        printf "${YELLOW}[✔] meteor ${libToInstall} (A new meteor version is available. Please, re-setup your environment)${NC}\n"
    else
        printf "${RED}[x] meteor ${libToInstall}${NC}\n"
    fi
}

function setupMeteorLib() {
    libToInstall=${1-''}

    if hasMeteorLib $@; then
        printf "${GREEN}[✔] Already meteor ${libToInstall}${NC}\n"
        return;
    fi

    installMeteorLib $@
}

function purgeMeteorLib() {
    libToInstall=${1-''}

    if ! hasMeteorLib $@; then
        return;
    fi

    uninstallMeteorLib $@
}

DEVICE_EMULATOR_ANDROID='android'
DEVICE_EMULATOR_IOS='ios'
DEVICE_ANDROID='android-device'
DEVICE_IOS='ios-device'

APPS_PATH='apps'
APP_CONFIG_PATH='private/config'

PORT=3000
APP_TO=''
ENV_TO='development'
ENV_OVERRIDE=''
DEVICES_TO=''

function loadMeteorEnv() {
    meteorEnvPath=./${APPS_PATH}/${APP_TO}/${APP_CONFIG_PATH}/${ENV_TO}/.env
    printf "${PURPLE} - Env Path: ${meteorEnvPath}${NC}\n"
    loadEnv ${meteorEnvPath}
}

function startMeteorApp() {
    APP_TO=${1-${APP_TO}}

    if [[ "${DEVICES_TO}" != '' ]]; then
        printf "${BLUE}[-] Starting \"${APP_TO}\" in ${DEVICES_TO}...${NC}\n"
    else
        printf "${BLUE}[-] Starting \"${APP_TO}\" app...${NC}\n"
    fi
    printf "${PURPLE} - Env: ${ENV_TO}${NC}\n"

    oldPWD=${PWD}
    cd ${PROJECT_PATH}/${APPS_PATH}/${APP_TO}

    loadMeteorEnv
    printf "${PURPLE} - Env Override: ${ENV_OVERRIDE}${NC}\n"
    eval ${ENV_OVERRIDE}

    meteorSettingsPath=./${APP_CONFIG_PATH}/${ENV_TO}/settings.json
    printf "${PURPLE} - Settings Path: ${meteorSettingsPath}${NC}\n"
    printf "${PURPLE} - Port: ${PORT}${NC}\n"

    trap "killMeteorApp ${@} && cd ${oldPWD}" SIGINT SIGTERM
    meteor run ${DEVICES_TO} --settings ${meteorSettingsPath} --port ${PORT} ${@:2}
}

function startMeteorAppInDevice() {
    if ! hasIfconfig; then
        setupIfconfig
    fi

    MOBILE_SERVER_TO=$(ifconfig | grep '\<inet\>' | cut -d ' ' -f2 | grep -v '127.0.0.1')
    startMeteorApp ${1} "--mobile-server ${MOBILE_SERVER_TO}:${PORT}" ${@:2}
}

function killMeteorApp() {
    APP_TO=${1-${APP_TO}}
    printf "${BLUE}[-] Killing \"${APP_TO}\" app...${NC}\n"

    loadMeteorEnv
    printf "${PURPLE} - Port: ${PORT}${NC}\n"

    killProcessByPort ${PORT}
}

function cleanMeteorApp() {
    APP_TO=${1-${APP_TO}}
    printf "${BLUE}[-] Cleaning \"${APP_TO}\" meteor app...${NC}\n"
    oldPWD=${PWD}
    cd ${PROJECT_PATH}/${APPS_PATH}/${APP_TO}
    meteor reset
    rm -rf ./node_modules
    cd ${oldPWD}
}
