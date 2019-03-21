#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasXcode() {
    isOSX && [[ "$(xcode-select -p | grep -ic "not found")" -eq "0" ]] && [[ -d /Applications/Xcode.app ]]
}

function installXcode() {
    printf "${BLUE}[-] Installing xcode...${NC}\n"
    brew install mas
    mas install 497799835
    xcode-select --install
}

function configXcode() {
    printf "${BLUE}[-] Configuring xcode...${NC}\n"
    sudo xcodebuild -license accept
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
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

function checkXcode() {
    if hasXcode; then
        printf "${GREEN}[✔] xcode${NC}\n"
    else
        printf "${RED}[x] xcode${NC}\n"
    fi
}

function setupXcode() {
    if hasXcode; then
        printf "${GREEN}[✔] Already xcode${NC}\n"
        return
    fi

    installXcode

    configXcode
}

function purgeXcode() {
    if ! isOSX; then
        return
    fi

    if ! hasXcode; then
        return
    fi

    uninstallXcode
}
