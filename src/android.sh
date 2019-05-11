#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasJavaInMac() {
    hasCurl && [[ "$(java -version 2>&1 | grep -ic "java version \"1.8")" -ne "0" ]]
}

function hasJavaInLinux() {
    hasCurl && [[ "$(java -version 2>&1 | grep -ic "java version \"1.8")" -ne "0" ]]
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
    if ! hasCurl; then
        setupCurl
    fi

    javaGDriveId="1HEqM3yZp4BtaeO-DiIG3YRtVRrpOu1tL"
    javaGDriveExtension="dmg"
    javaGDriveFilename="${javaGDriveId}.${javaGDriveExtension}"
    javaGDriveOutput="/tmp/${javaGDriveFilename}"

    if [[ ! -f ${javaGDriveOutput} ]]; then
        downloadFromGoogleDrive ${javaGDriveId} ${javaGDriveExtension} ${javaGDriveOutput}
    fi

    sudo hdiutil attach ${javaGDriveOutput}
    sudo installer -package /Volumes/JDK\ 8\ Update\ 211/JDK\ 8\ Update\ 211.pkg -target /
    sudo hdiutil detach /Volumes/JDK\ 8\ Update\ 211
}

function installJavaInLinux() {
    printf "${BLUE}[-] Installing Java 8...${NC}\n"
    if ! hasCurl; then
        setupCurl
    fi

    javaGDriveId="1BXCxKFOwtGQit3cbefRmEj5VG_R62o2g"
    javaGDriveExtension="tar.gz"
    javaGDriveFilename="${javaGDriveId}.${javaGDriveExtension}"
    javaGDriveOutput="/tmp/${javaGDriveFilename}"

    if [[ ! -f ${javaGDriveOutput} ]]; then
        downloadFromGoogleDrive ${javaGDriveId} ${javaGDriveExtension} ${javaGDriveOutput}
    fi

    sudo mkdir /usr/lib/jvm
    sudo tar xvzf ${javaGDriveOutput} -C /usr/lib/jvm
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
    [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_HOME_MAC}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_PATH_MAC}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_SDK_MAC}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "export JAVA_HOME=$(/usr/libexec/java_home -v1.8)")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "export PATH=\$PATH:\$JAVA_HOME/bin")" -ne "0" ]]
}

function configAndroidInMac() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"

    sedi '/JAVA_HOME/d' ~/.envrc
    sedi '/ANDROID_HOME/d' ~/.envrc
    sedi '/ANDROID_SDK_ROOT/d' ~/.envrc

    tryPrintNewLine ~/.envrc
    echo "export JAVA_HOME=$(/usr/libexec/java_home -v1.8)" >>~/.envrc
    export JAVA_HOME=$(/usr/libexec/java_home -v1.8)

    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >>~/.envrc
    export PATH=$PATH:$JAVA_HOME/bin

    echo "${EXPORT_ANDROID_HOME_MAC}" >>~/.envrc
    echo "${EXPORT_ANDROID_PATH_MAC}" >>~/.envrc
    echo "${EXPORT_ANDROID_SDK_MAC}" >>~/.envrc

    eval "${EXPORT_ANDROID_HOME_MAC}"
    eval "${EXPORT_ANDROID_PATH_MAC}"
    eval "${EXPORT_ANDROID_SDK_MAC}"

    setupAndroidSDK 28
    setupAndroidSDK 27
}

EXPORT_ANDROID_HOME_LINUX="export ANDROID_HOME=~/Android/Sdk"
EXPORT_ANDROID_PATH_LINUX="export PATH=\$PATH:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/platform-tools"
EXPORT_ANDROID_SDK_LINUX="export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\""

function hasAndroidConfigInLinux() {
    [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_HOME_LINUX}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_PATH_LINUX}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_SDK_LINUX}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_211")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "export PATH=\$PATH:\$JAVA_HOME/bin")" -ne "0" ]]
}

function configAndroidInLinux() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"

    sedi '/JAVA_HOME/d' ~/.envrc
    sedi '/ANDROID_HOME/d' ~/.envrc
    sedi '/ANDROID_SDK_ROOT/d' ~/.envrc

    tryPrintNewLine ~/.envrc
    echo "export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_211" >>~/.envrc
    export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_211

    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >>~/.envrc
    export PATH=$PATH:$JAVA_HOME/bin

    echo "${EXPORT_ANDROID_HOME_LINUX}" >>~/.envrc
    echo "${EXPORT_ANDROID_PATH_LINUX}" >>~/.envrc
    echo "${EXPORT_ANDROID_SDK_LINUX}" >>~/.envrc

    eval "${EXPORT_ANDROID_HOME_LINUX}"
    eval "${EXPORT_ANDROID_PATH_LINUX}"
    eval "${EXPORT_ANDROID_SDK_LINUX}"
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

    if isOSX; then
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
    elif isLinux; then
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

function setupAndroidSDK() {
    version=${1-'26'}

    printf "${BLUE}[-] Setting up android sdk ${version}...${NC}\n"

    yes | sdkmanager "platforms;android-${version}" "build-tools;${version}.0.0"
}

function uninstallJavaInMac() {
    printf "${BLUE}[-] Uninstalling Java 8...${NC}\n"
    sudo rm -rf "$(/usr/libexec/java_home -v1.8)"
    sedi '/JAVA_HOME/d' ~/.envrc
}

function uninstallJavaInLinux() {
    printf "${BLUE}[-] Uninstalling Java 8...${NC}\n"
    sudo rm -rf /usr/lib/jvm/jdk1.8.0_211
    sedi '/JAVA_HOME/d' ~/.envrc
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
