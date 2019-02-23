#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasCodeInsiders() {
    [[ "$(which code-insiders | grep -ic "not found")" -eq "0" ]]
}

function installCodeInsiders() {
    printf "${BLUE}[-] Installing code-insiders...${NC}\n"
    if isOSX; then
        brew tap homebrew/cask-versions
        brew cask install visual-studio-code-insiders
    else
        sudo apt-get install snapd
        sudo snap install code-insiders --classic
    fi
}

function uninstallCodeInsiders() {
    printf "${BLUE}[-] Uninstalling code-insiders...${NC}\n"
    if isOSX; then
        $(which code-insiders) --uninstall-extension shan.code-settings-sync
        brew cask uninstall visual-studio-code-insiders
    else
        sudo snap remove code-insiders --classic
    fi
}

function runCodeInsiders() {
    $(which code-insiders) .
}

function getSyncPluginConfigPath() {
    if isOSX; then
        configFile=~/Library/Application\ Support/Code\ -\ Insiders/User/syncLocalSettings.json
    elif isLinux; then
        configFile=~/.config/Code\ -\ Insiders/User/syncLocalSettings.json
    fi
    echo "${configFile}"
}

function hasCodeInsidersConfig() {
    [[ "$($(which code-insiders) --list-extensions | grep -ic "shan.code-settings-sync")" -eq "1" ]] &&
        [[ "$(cat "$(getSyncPluginConfigPath)" | grep -ic "\"downloadPublicGist\":true")" -eq "1" ]]
}

function configCodeInsiders() {
    printf "${BLUE}[-] Configuring code-insiders...${NC}\n"

    $(which code-insiders) --install-extension shan.code-settings-sync

    if isOSX; then
        brew install jq
    elif isLinux; then
        sudo apt-get install jq -y
    fi

    local configFile="$(getSyncPluginConfigPath)";
    if [[ -f "${configFile}" ]]; then
        jsonStr=$(cat "${configFile}")
        echo "$(jq -c '. + { "downloadPublicGist":true }' <<<"$jsonStr")" > "${configFile}"
    else
        echo "$(jq -c '. + { "downloadPublicGist":true }' <<<"{}")" > "${configFile}"
    fi

    runCodeInsiders
}

function purgeCodeInsidersConfig() {
    printf "${BLUE}[-] Purging code-insiders config...${NC}\n"
    local configFile;
    local configFile="$(getSyncPluginConfigPath)";
    rm "${configFile}"
}

function checkCodeInsiders() {
    if hasCodeInsiders && hasCodeInsidersConfig; then
        printf "${GREEN}[✔] code-insiders${NC}\n"
    else
        printf "${RED}[x] code-insiders${NC}\n"
    fi
}

function setupCodeInsiders() {
    if hasCodeInsiders && hasCodeInsidersConfig; then
        printf "${GREEN}[✔] Already code-insiders${NC}\n"
        return
    fi

    if ! hasCodeInsiders; then
        installCodeInsiders
    fi

    if ! hasCodeInsidersConfig; then
        configCodeInsiders
    fi
}

function purgeCodeInsiders() {
    if hasCodeInsiders; then
        uninstallCodeInsiders
    fi

    purgeCodeInsidersConfig
}
