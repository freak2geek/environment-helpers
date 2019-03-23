#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasAndroidInMac() {
    [[ "$(brew cask list 2>&1 | grep -ic "java8")" -ne "0" ]] &&
        [[ "$(brew cask list 2>&1 | grep -ic "android-sdk")" -ne "0" ]] &&
        [[ "$(brew ls gradle 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function installJavaInMac() {
    printf "${BLUE}[-] Installing Java 8...${NC}\n"
    brew tap homebrew/cask-versions
    brew cask install homebrew/cask-versions/java8
}

function installAndroidSDKInMac() {
    printf "${BLUE}[-] Installing Android SDK...${NC}\n"
    brew install gradle
    brew cask install android-sdk
    brew cask install android-platform-tools
}

function installAndroidStudioInMac() {
    printf "${BLUE}[-] Installing Android Studio...${NC}\n"
    brew cask install android-studio
}

function configAndroid() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"
    tryPrintNewLine ~/.envrc
    echo "export ANDROID_HOME=/usr/local/share/android-sdk" >>~/.envrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools" >>~/.envrc
    echo "export ANDROID_SDK_ROOT=\"/usr/local/share/android-sdk\"" >>~/.envrc
    export ANDROID_HOME=/usr/local/share/android-sdk
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
    yes | sdkmanager "platform-tools" "platforms;android-26"
    yes | sdkmanager "build-tools;26.0.0"
}

function checkAndroid() {
    if isOSX && hasAndroidInMac && hasAndroidConfig; then
        printf "${GREEN}[✔] android${NC}\n"
    else
        printf "${RED}[x] android${NC}\n"
    fi
}

function hasAndroidConfig() {
    [[ "$(cat ~/.envrc | grep -ic "export ANDROID_HOME=/usr/local/share/android-sdk")" -ne "0" ]]
}

function setupAndroid() {
    if hasAndroidInMac && hasAndroidConfig; then
        printf "${GREEN}[✔] Already android${NC}\n"
        return
    fi

    printf "${BLUE}[-] Setting up android...${NC}\n"

    if isOSX && ! hasAndroidInMac; then
        installJavaInMac
        installAndroidSDKInMac
        installAndroidStudioInMac
    fi

    if ! hasAndroidConfig; then
        configAndroid
    fi
}

function uninstallJavaInMac() {
    printf "${BLUE}[-] Uninstalling Java 8...${NC}\n"
    brew cask uninstall homebrew/cask-versions/java8
    rm -rf ~/Library/Java
    rm -fr /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin
    rm -fr /Library/PreferencePanes/JavaControlPanel.prefPane
    rm -fr ~/Library/Application\ Support/Oracle/Java
}

function uninstallAndroidSDKInMac() {
    printf "${BLUE}[-] Uninstalling Android SDK...${NC}\n"
    brew uninstall gradle
    brew cask uninstall android-sdk
    brew cask uninstall android-platform-tools
}

function uninstallAndroidStudioInMac() {
    printf "${BLUE}[-] Uninstalling Android Studio...${NC}\n"
    brew cask uninstall android-studio
}

function purgeAndroidConfig() {
    printf "${BLUE}[-] Purging Android Config...${NC}\n"
    sedi '/ANDROID_HOME/d' ~/.envrc
    sedi '/ANDROID_SDK_ROOT/d' ~/.envrc
}

function purgeAndroid() {
    printf "${BLUE}[-] Purging android...${NC}\n"

    if isOSX; then
        uninstallJavaInMac
        uninstallAndroidSDKInMac
        uninstallAndroidStudioInMac
        purgeAndroidConfig
    fi
}
