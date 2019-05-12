#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"
source "./src/meteor.sh"

function hasMeteorYarn() {
    hasMeteor && hasLibForCurrentMeteor yarn
}

function installMeteorYarn() {
    installMeteorLib yarn
}

function uninstallMeteorYarn() {
    uninstallMeteorLib yarn
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

    if hasMeteorLib yarn && hasMeteorYarnConfig; then
        printf "${GREEN}[✔] Already meteor yarn${NC}\n"
        return
    fi

    if ! hasMeteorLib yarn; then
        if [[ -d ~/.npm ]]; then
            sudo chown -R $(whoami) ~/.npm
            sudo chmod -R 777 ~/.npm
        fi
        installMeteorYarn
    fi

    if ! hasMeteorYarnConfig; then
        configMeteorYarn
    fi
}

function purgeMeteorYarn() {
    if ! hasMeteorLib yarn; then
        return
    fi

    uninstallMeteorYarn
    rm -rf ~/.cache
}

function getPackageName() {
    packagePath=${1-"."}
    cd ${PROJECT_PATH}/${packagePath}
    cat package.json | sed -n 's@.*"name": "\(.*\)".*@\1@p'
}

function hasYarnDeps() {
    packagePath=${1-"."}
    [[ "$(meteor yarn check --verify-tree 2>&1 >/dev/null | grep -ic "error")" -eq "0" ]]
}

function checkYarnDeps() {
    oldPath=${PWD}
    packagePath=${1-"."}
    package=${2-$(getPackageName $@)}

    cd ${PROJECT_PATH}/${packagePath}
    if hasMeteorYarn && hasYarnDeps $@; then
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
    cd ${PROJECT_PATH}/${packagePath}
    if ! hasMeteorYarn; then
        installMeteorYarn
    fi
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

    meteor yarn --cwd ${PROJECT_PATH}/${APPS_PATH}/${APP_TO} install ${@:2}
}

function cleanApp() {
    APP_TO=${1-${APP_TO}}
    printf "${BLUE}[-] Cleaning \"${APP_TO}\" app...${NC}\n"
    rm -rf ${PROJECT_PATH}/${APPS_PATH}/${APP_TO}/node_modules
}
