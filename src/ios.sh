#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasXcode() {
    [[ "$(xcode-select -p | grep -ic "not found")" -eq "0" ]] && [[ -d /Applications/Xcode.app ]]
}

function hasCocoapods() {
    [[ "$(gem list | grep -ic "cocoapods")" -ne "0" ]]
}

function hasIos() {
    isOSX && hasXcode && hasCocoapods
}

function installXcode() {
    printf "${BLUE}[-] Installing xcode...${NC}\n"
    brew install mas
    mas install 497799835
    xcode-select --install
    sudo xcodebuild -license accept
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
}

function installCocoapods() {
    printf "${BLUE}[-] Installing cocoapods...${NC}\n"
    sudo gem install cocoapods
    pod setup
}

function installIos() {
    printf "${BLUE}[-] Installing ios...${NC}\n"

    if ! hasXcode; then
        installXcode
    fi

    if ! hasCocoapods; then
        installCocoapods
    fi
}

function uninstallXcode() {
    printf "${BLUE}[-] Uninstalling xcode...${NC}\n"
    sudo rm -rf /Applications/Xcode.app
    sudo rm -rf /Library/Developer/CommandLineTools
    sudo rm -rf ~/Library/Caches/com.apple.dt.Xcode
    sudo rm -rf ~/Library/Developer
    sudo rm -f ~/Library/MobileDevice
    sudo rm -f ~/Library/Preferences/com.apple.dt.Xcode.plist
    sudo rm -f /Library/Preferences/com.apple.dt.Xcode.plist
    sudo rm -f /System/Library/Receipts/com.apple.pkg.XcodeExtensionSupport.bom
    sudo rm -f /System/Library/Receipts/com.apple.pkg.XcodeExtensionSupport.plist
}

function uninstallCocoapods() {
    printf "${BLUE}[-] Uninstalling cocoapods...${NC}\n"
    yes | sudo gem uninstall cocoapods
    yes | sudo gem uninstall cocoapods-core
    yes | sudo gem uninstall cocoapods-deintegrate
    yes | sudo gem uninstall cocoapods-downloader
    yes | sudo gem uninstall cocoapods-plugins
    yes | sudo gem uninstall cocoapods-search
    yes | sudo gem uninstall cocoapods-stats
    yes | sudo gem uninstall cocoapods-trunk
    yes | sudo gem uninstall cocoapods-try
}

function uninstallIos() {
    printf "${BLUE}[-] Uninstalling ios...${NC}\n"
    uninstallXcode
    uninstallCocoapods
}

function checkIos() {
    if hasIos; then
        printf "${GREEN}[✔] ios${NC}\n"
    elif ! isOSX; then
        printf "${PURPLE}[-] ios. Only supported in macOS.${NC}\n"
    else
        printf "${RED}[x] ios${NC}\n"
    fi
}

function setupIos() {
    if ! isOSX; then
        return
    fi

    if hasIos; then
        printf "${GREEN}[✔] Already ios${NC}\n"
        return
    fi

    installIos
}

function purgeIos() {
    if ! isOSX; then
        return
    fi

    if ! hasIos; then
        return
    fi

    uninstallIos
}
