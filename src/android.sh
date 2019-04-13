#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasJavaInMac() {
    [[ "$(brew cask list 2>&1 | grep -ic "java8")" -ne "0" ]]
}

function hasAndroidSDKInMac() {
    [[ "$(brew cask list 2>&1 | grep -ic "android-sdk")" -ne "0" ]] &&
        [[ "$(brew ls gradle 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function hasAndroidStudioInMac() {
    [[ "$(brew cask list 2>&1 | grep -ic "android-studio")" -ne "0" ]]
}

function hasAndroidInMac() {
    hasJavaInMac && hasAndroidStudioInMac && hasAndroidSDKInMac
}

function hasJavaInLinux() {
    [[ "$(apt list oracle-java8-installer 2>&1 | grep -ic "installed")" -ne "0" ]]
}

function hasAndroidStudioInLinux() {
    [[ "$(snap list android-studio 2>&1 | grep -ic "no matching snaps")" -eq "0" ]]
}

function hasAndroidSDKInLinux() {
    [[ -d ~/Android/Sdk ]]
}

function hasAndroidInLinux() {
    hasJavaInLinux && hasAndroidStudioInLinux && hasAndroidSDKInLinux
}

function installJavaInMac() {
    printf "${BLUE}[-] Installing Java 8...${NC}\n"
    brew tap homebrew/cask-versions
    brew cask install homebrew/cask-versions/java8
}

function installJavaInLinux() {
    printf "${BLUE}[-] Installing Java 8...${NC}\n"
    sudo dpkg --configure -a
    yes | sudo add-apt-repository ppa:webupd8team/java
    yes | sudo apt update
    sudo apt install oracle-java8-installer
    yes | sudo apt install oracle-java8-set-default
}

function installAndroidSDKInMac() {
    printf "${BLUE}[-] Installing Android SDK...${NC}\n"
    brew install gradle
    brew cask install android-sdk
    brew cask install android-platform-tools
    mkdir -p ~/Library/Android
    ln -s /usr/local/share/android-sdk ~/Library/Android
    mv ~/Library/Android/android-sdk ~/Library/Android/sdk
}

function installAndroidSDKInLinux() {
    printf "${BLUE}[-] Installing Android SDK...${NC}\n"
    snap run android-studio
}

function installAndroidStudioInMac() {
    printf "${BLUE}[-] Installing Android Studio...${NC}\n"
    brew cask install android-studio
}

function installAndroidStudioInLinux() {
    printf "${BLUE}[-] Installing Android Studio...${NC}\n"
    yes | sudo snap install android-studio --classic
}

function checkAndroid() {
    if isOSX && hasAndroidInMac && hasAndroidConfigInMac; then
        printf "${GREEN}[✔] android${NC}\n"
    elif isLinux && hasAndroidInLinux && hasAndroidConfigInLinux; then
        printf "${GREEN}[✔] android${NC}\n"
    else
        printf "${RED}[x] android${NC}\n"
    fi
}

EXPORT_ANDROID_HOME_MAC="export ANDROID_HOME=~/Library/Android/sdk"
EXPORT_ANDROID_PATH_MAC="export PATH=\$PATH:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/platform-tools"
EXPORT_ANDROID_SDK_MAC="export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\""

function hasAndroidConfigInMac() {
    [[ "$(cat ~/.envrc | grep -ic ${EXPORT_ANDROID_HOME_MAC})" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic ${EXPORT_ANDROID_PATH_MAC})" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic ${EXPORT_ANDROID_SDK_MAC})" -ne "0" ]]
}

function configAndroidInMac() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"
    tryPrintNewLine ~/.envrc

    echo "export JAVA_HOME=$(/usr/libexec/java_home -v1.8)" >>~/.envrc
    export JAVA_HOME=$(/usr/libexec/java_home -v1.8)

    echo ${EXPORT_ANDROID_HOME_MAC} >>~/.envrc
    echo ${EXPORT_ANDROID_PATH_MAC} >>~/.envrc
    echo ${EXPORT_ANDROID_SDK_MAC} >>~/.envrc

    eval ${EXPORT_ANDROID_HOME_MAC}
    eval ${EXPORT_ANDROID_PATH_MAC}
    eval ${EXPORT_ANDROID_SDK_MAC}

    yes | sdkmanager "platform-tools" "platforms;android-28" "build-tools;28.0.0"
}

EXPORT_ANDROID_HOME_LINUX="export ANDROID_HOME=~/Android/Sdk"
EXPORT_ANDROID_PATH_LINUX="export PATH=\$PATH:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/platform-tools"
EXPORT_ANDROID_SDK_LINUX="export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\""

function hasAndroidConfigInLinux() {
    [[ "$(cat ~/.envrc | grep -ic ${EXPORT_ANDROID_HOME_LINUX})" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic ${EXPORT_ANDROID_PATH_LINUX})" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic ${EXPORT_ANDROID_SDK_LINUX})" -ne "0" ]]
}

function configAndroidInLinux() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"
    tryPrintNewLine ~/.envrc

    echo ${EXPORT_ANDROID_HOME_LINUX} >>~/.envrc
    echo ${EXPORT_ANDROID_PATH_LINUX} >>~/.envrc
    echo ${EXPORT_ANDROID_SDK_LINUX} >>~/.envrc

    eval ${EXPORT_ANDROID_HOME_LINUX}
    eval ${EXPORT_ANDROID_PATH_LINUX}
    eval ${EXPORT_ANDROID_SDK_LINUX}
}

function setupAndroid() {
    if hasAndroidInMac && hasAndroidConfigInMac; then
        printf "${GREEN}[✔] Already android${NC}\n"
        return
    elif hasAndroidInLinux && hasAndroidConfigInLinux; then
        printf "${GREEN}[✔] Already android${NC}\n"
        return
    fi

    printf "${BLUE}[-] Setting up android...${NC}\n"

    if isOSX && ! hasAndroidInMac; then
        if ! hasJavaInMac; then
            installJavaInMac
        fi
        if ! hasAndroidSDKInMac; then
            installAndroidSDKInMac
        fi
        if ! hasAndroidStudioInMac; then
            installAndroidStudioInMac
        fi

        if ! hasAndroidConfigInMac; then
            configAndroidInMac
        fi
    elif isLinux && ! hasAndroidInLinux; then
        if ! hasJavaInLinux; then
            installJavaInLinux
        fi
        if ! hasAndroidStudioInLinux; then
            installAndroidStudioInLinux
        fi
        if ! hasAndroidConfigInLinux; then
            configAndroidInLinux
        fi
        if ! hasAndroidSDKInLinux; then
            installAndroidSDKInLinux
        fi
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

function uninstallJavaInLinux() {
    printf "${BLUE}[-] Uninstalling Java 8...${NC}\n"
    yes | sudo apt remove oracle-java8-set-default --purge
    yes | sudo apt remove oracle-java8-installer --purge
}

function uninstallAndroidSDKInMac() {
    printf "${BLUE}[-] Uninstalling Android SDK...${NC}\n"
    brew uninstall gradle
    brew cask uninstall android-sdk
    brew cask uninstall android-platform-tools
}

function uninstallAndroidSDKInLinux() {
    printf "${BLUE}[-] Uninstalling Android SDK...${NC}\n"
    rm -rf ~/Android/Sdk
}

function uninstallAndroidStudioInMac() {
    printf "${BLUE}[-] Uninstalling Android Studio...${NC}\n"
    brew cask uninstall android-studio
}

function uninstallAndroidStudioInLinux() {
    printf "${BLUE}[-] Uninstalling Android Studio...${NC}\n"
    yes | sudo snap remove android-studio
}

function purgeAndroidConfig() {
    printf "${BLUE}[-] Purging Android Config...${NC}\n"
    sedi '/JAVA_HOME/d' ~/.envrc
    sedi '/ANDROID_HOME/d' ~/.envrc
    sedi '/ANDROID_SDK_ROOT/d' ~/.envrc
}

function purgeAndroid() {
    printf "${BLUE}[-] Purging android...${NC}\n"

    if isOSX; then
        uninstallJavaInMac
        uninstallAndroidSDKInMac
        uninstallAndroidStudioInMac
    elif isLinux; then
        uninstallJavaInLinux
        uninstallAndroidSDKInLinux
        uninstallAndroidStudioInLinux
    fi
    purgeAndroidConfig
}
