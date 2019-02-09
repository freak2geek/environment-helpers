#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"
source "./src/meteor.sh"

function hasMeteorYarn() {
    hasMeteor && find ${METEOR_TOOL_DIR} -type d -name "yarn" | grep -icq "yarn"
}

function installMeteorYarn() {
    printf "${BLUE}[-] Installing meteor yarn...${NC}\n"
    sudo chmod -R 777 ~/.npm
    meteor npm install yarn -g
}

function uninstallMeteorYarn() {
    printf "${BLUE}[-] Uninstalling meteor yarn...${NC}\n"
    meteor npm uninstall yarn -g
}

function hasMeteorYarnConfig() {
    [[ -d ~/.cache ]] && ls -la ~ | grep -icq "drwxrwxrwx .* \.cache"
}

function configMeteorYarn() {
    printf "${BLUE}[-] Configuring meteor yarn...${NC}\n"
    [[ ! -d ~/.cache ]] && mkdir ~/.cache
    sudo chmod 777 ~/.cache
}

function checkMeteorYarn() {
    if hasMeteorYarn && hasMeteorYarnConfig; then
        printf "${GREEN}[✔] meteor yarn${NC}\n"
    else
        printf "${RED}[x] meteor yarn${NC}\n"
    fi
}

function setupMeteorYarn() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorYarn && hasMeteorYarnConfig; then
        printf "${GREEN}[✔] Already meteor yarn${NC}\n"
        return
    fi

    if ! hasMeteorYarn; then
        installMeteorYarn
    fi

    if ! hasMeteorYarnConfig; then
        configMeteorYarn
    fi
}

function purgeMeteorYarn() {
    if ! hasMeteorYarn; then
        return
    fi

    uninstallMeteorYarn
    rm -rf ~/.cache
}

function getPackageName() {
    packagePath=${1-"."}
    cd ${packagePath}
    cat package.json | sed -n 's@.*"name": "\(.*\)".*@\1@p'
}

function hasYarnDeps() {
    packagePath=${1-"."}
    cd ${packagePath}
    hasMeteorYarn && [[ "$(meteor yarn check --verify-tree 2>&1 >/dev/null | grep -ic "error")" -eq "0" ]]
}

function checkYarnDeps() {
    oldPath=${PWD}
    packagePath=${1-"."}
    package=${2-$(getPackageName $@)}

    if hasYarnDeps $@; then
        printf "${GREEN}[✔] \"${package}\" dependencies${NC}\n"
    else
        printf "${RED}[x] \"${package}\" dependencies${NC}\n"
    fi

    cd ${oldPath}
}

function installYarnDeps() {
    oldPath=${PWD}
    packagePath=${1-"."}
    package=${2-$(getPackageName $@)}

    printf "${BLUE}[-] Installing \"${package}\" dependencies...${NC}\n"
    cd ${packagePath}
    meteor yarn install
    cd ${oldPath}
}

function setupYarnDeps() {
    oldPath=${PWD}
    packagePath=${1-"."}
    package=${2-$(getPackageName $@)}

    if hasYarnDeps $@; then
        printf "${GREEN}[✔] Already \"${package}\" dependencies${NC}\n"
        return
    fi

    installYarnDeps $@
}

function checkApp() {
    APP_TO=${1-${APP_TO}}
    printf "${BLUE}[-] Checking \"${APP_TO}\" app...${NC}\n"

    checkYarnDeps ./${APPS_PATH}/${APP_TO}
}

function setupApp() {
    APP_TO=${1-${APP_TO}}
    printf "${BLUE}[-] Installing \"${APP_TO}\" app...${NC}\n"

    meteor yarn --cwd ./${APPS_PATH}/${APP_TO} install ${@:2}
}

function cleanApp() {
    APP_TO=${1-${APP_TO}}
    printf "${BLUE}[-] Cleaning \"${APP_TO}\" app...${NC}\n"

    rm -rf ./${APPS_PATH}/${APP_TO}/node_modules
}
