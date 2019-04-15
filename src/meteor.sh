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

PACKAGES_FOLDER='packages'
SRC_FOLDER='src'
ENV_FILENAME='.env'

function loadMeteorEnv() {
    meteorEnvPath=./${APP_CONFIG_PATH}/${ENV_TO}/${ENV_FILENAME}
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
    printEnv ${meteorEnvPath} "    - "

    envOverridePath="${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
    if [[ -f ${envOverridePath} ]]; then
        printf "${PURPLE} - Env Override: ./${ENV_OVERRIDE_FILENAME}${NC}\n"
        loadOverrides
        printEnv ${envOverridePath} "    - "
    fi

    meteorSettingsPath=./${APP_CONFIG_PATH}/${ENV_TO}/settings.json
    printf "${PURPLE} - Settings Path: ${meteorSettingsPath}${NC}\n"
    printf "${PURPLE} - Port: ${PORT}${NC}\n"

    trap "killMeteorApp ${APP_TO} && cd ${oldPWD}" SIGINT SIGTERM
    meteor run ${DEVICES_TO} --settings ${meteorSettingsPath} --port ${PORT} ${@:2}
}

function startMeteorAppInDevice() {
    if ! hasIfconfig; then
        setupIfconfig
    fi

    MOBILE_SERVER_TO=$(getLocalIp)
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

function addPackagesSymlinksForMeteorApp() {
    printf "${BLUE}[-] Linking packages for \"${APP_TO}\" app...${NC}\n"

    APP_TO=${1-${APP_TO}}

    rootPackagesPath=${PROJECT_PATH}/${PACKAGES_FOLDER}
    rootPackageName="@$(getNpmPackageName "${PROJECT_PATH}/package.json")"

    appPath=${PROJECT_PATH}/${APPS_PATH}/${APP_TO}
    appPackagesPath=${appPath}/${PACKAGES_FOLDER}
    appPackagesSrcPath=${appPath}/${SRC_FOLDER}/${PACKAGES_FOLDER}
    appPackageName="@${APP_TO}"

    mkdir -p ${appPackagesSrcPath}

    if [[ -d ${rootPackagesPath} ]] && [[ ! -L "${appPackagesSrcPath}/${rootPackageName}" ]]; then
        ln -s "${rootPackagesPath}" "${appPackagesSrcPath}/${rootPackageName}"
        printf "${GREEN}[✔] ${rootPackageName}${NC}\n"
    fi
    if [[ -d ${appPackagesPath} ]] && [[ ! -L "${appPackagesSrcPath}/${appPackageName}" ]]; then
        ln -s "${appPackagesPath}" "${appPackagesSrcPath}/${appPackageName}"
        printf "${GREEN}[✔] ${appPackageName}${NC}\n"
    fi
}

function removePackagesSymlinksForMeteorApp() {
    printf "${BLUE}[-] Unlinking packages for \"${APP_TO}\" app...${NC}\n"

    APP_TO=${1-${APP_TO}}

    rootPackageName="@$(getNpmPackageName "${PROJECT_PATH}/package.json")"

    appPath=${PROJECT_PATH}/${APPS_PATH}/${APP_TO}
    appPackagesSrcPath=${appPath}/${SRC_FOLDER}/${PACKAGES_FOLDER}
    appPackageName="@${APP_TO}"

    rm -f "${appPackagesSrcPath}/${rootPackageName}"
    rm -f "${appPackagesSrcPath}/${appPackageName}"
    rm -rf "${appPackagesSrcPath}"
}
