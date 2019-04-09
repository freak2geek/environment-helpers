#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasAndroidInMac() {
    [[ "$(brew cask list 2>&1 | grep -ic "java8")" -ne "0" ]] &&
        [[ "$(brew cask list 2>&1 | grep -ic "android-sdk")" -ne "0" ]] &&
        [[ "$(brew ls gradle 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function hasAndroidInLinux() {
    [[ "$(apt list oracle-java8-installer 2>&1 | grep -ic "installed")" -ne "0" ]] &&
        [[ "$(apt list android-sdk 2>&1 | grep -ic "installed")" -ne "0" ]] &&
        [[ "$(snap list android-studio 2>&1 | grep -ic "no matching snaps")" -eq "0" ]]
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
}

function installAndroidSDKInLinux() {
    printf "${BLUE}[-] Installing Android SDK...${NC}\n"
    yes | sudo apt update
    yes | sudo apt install android-sdk
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

function hasAndroidConfigInMac() {
    [[ "$(cat ~/.envrc | grep -ic "export ANDROID_HOME")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "export JAVA_HOME")" -ne "0" ]]
}

function configAndroidInMac() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"
    tryPrintNewLine ~/.envrc

    echo "export JAVA_HOME=$(/usr/libexec/java_home -v1.8)" >>~/.envrc
    export JAVA_HOME=$(/usr/libexec/java_home -v1.8)

    echo "export ANDROID_HOME=/usr/local/share/android-sdk" >>~/.envrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools" >>~/.envrc
    echo "export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\"" >>~/.envrc
    export ANDROID_HOME=/usr/local/share/android-sdk
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    export ANDROID_SDK_ROOT="${ANDROID_HOME}"

    yes | sdkmanager "platform-tools" "platforms;android-26"
    yes | sdkmanager "build-tools;26.0.0"
}

function hasAndroidConfigInLinux() {
    [[ "$(cat ~/.envrc | grep -ic "export ANDROID_HOME")" -ne "0" ]]
}

function configAndroidInLinux() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"
    tryPrintNewLine ~/.envrc

    echo "export ANDROID_HOME=/usr/lib/android-sdk" >>~/.envrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools" >>~/.envrc
    echo "export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\"" >>~/.envrc
    export ANDROID_HOME=/usr/lib/android-sdk
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    export ANDROID_SDK_ROOT="${ANDROID_HOME}"

    yes | sdkmanager "platform-tools" "platforms;android-26"
    yes | sdkmanager "build-tools;26.0.0"
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
        installJavaInMac
        installAndroidSDKInMac
        installAndroidStudioInMac
    elif isLinux && ! hasAndroidInLinux; then
        installJavaInLinux
        installAndroidSDKInLinux
        installAndroidStudioInLinux
    fi

    if isOSX && ! hasAndroidConfigInMac; then
        configAndroidInMac
    elif isLinux && ! hasAndroidConfigInLinux; then
        configAndroidInLinux
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
    yes | sudo apt install oracle-java8-set-default --purge
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
    yes | sudo apt remove android-sdk --purge
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
