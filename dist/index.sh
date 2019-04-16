#!/usr/bin/env bash
# @freak2geek/scripts - 1.6.7



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
    [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_HOME_MAC}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_PATH_MAC}")" -ne "0" ]] &&
        [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_SDK_MAC}")" -ne "0" ]]
}

function configAndroidInMac() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"
    tryPrintNewLine ~/.envrc

    echo "export JAVA_HOME=$(/usr/libexec/java_home -v1.8)" >>~/.envrc
    export JAVA_HOME=$(/usr/libexec/java_home -v1.8)

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
        [[ "$(cat ~/.envrc | grep -ic "${EXPORT_ANDROID_SDK_LINUX}")" -ne "0" ]]
}

function configAndroidInLinux() {
    printf "${BLUE}[-] Configuring Android...${NC}\n"
    tryPrintNewLine ~/.envrc

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

function setupAndroidSDK() {
    version=${1-'26'}

    printf "${BLUE}[-] Setting up android sdk ${version}...${NC}\n"

    yes | sdkmanager "platforms;android-${version}" "build-tools;${version}.0.0"
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


BREW_PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:~/.linuxbrew/bin:~/.linuxbrew/sbin"
BREW_UMASK="umask 002"

BREW_OS_DEPENDENCIES="build-essential curl g++ file git m4 texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev gawk make patch tcl"

function setupBrewOS() {
    sudo apt-get update -y &&
        sudo apt-get update --fix-missing -y &&
        sudo apt-get install --no-install-recommends ${BREW_OS_DEPENDENCIES} -y &&
        sudo apt autoremove -y
}

function purgeBrewOS() {
    sudo apt-get remove --purge ${BREW_OS_DEPENDENCIES} -y &&
        sudo apt autoremove -y
}

function hasLinuxBrew() {
    [[ "$(brew --version 2>&1 | grep -ic "not")" -eq "0" ]]
}

function hasOsxBrew() {
    which brew >/dev/null && [[ "$(which brew | grep -ic "not found")" -eq "0" ]]
}

function hasBrewPathConfig() {
    hasEnvrc && cat ~/.envrc | grep -icq "${BREW_PATH}"
}

function hasBrewUmaskConfig() {
    hasEnvrc && cat ~/.envrc | grep -icq "${BREW_UMASK}"
}

function hasBrewConfig() {
   hasBrewPathConfig && hasBrewUmaskConfig
}

function hasBrewByOS() {
    (isLinux && hasCurl && hasLinuxBrew && hasBrewConfig) || (isOSX && hasCurl && hasOsxBrew)
}

function installBrewInLinux() {
    if ! hasCurl; then
        setupCurl
    fi

    printf "${BLUE}[-] Installing brew...${NC}\n"
    setupBrewOS
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    export PATH="${BREW_PATH}:$PATH"
    eval "${BREW_UMASK}"
    brew install gcc
}

function installBrewInOSX() {
    printf "${BLUE}[-] Installing brew...${NC}\n"
    yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function configBrewInLinux() {
    configEnvrc

    printf "${BLUE}[-] Configuring brew...${NC}\n"

    if ! hasBrewPathConfig; then
        tryPrintNewLine ~/.envrc
        echo "export PATH='${BREW_PATH}'":'"$PATH"' >>~/.envrc
    fi

    if ! hasBrewUmaskConfig; then
        tryPrintNewLine ~/.envrc
        echo "${BREW_UMASK}" >>~/.envrc
    fi
}

function uninstallBrewInLinux() {
    if isOSX; then
        return
    fi

    if hasBrewByOS; then
        if ! hasCurl; then
            setupCurl
        fi
        brew install ruby
        printf "${BLUE}[-] Uninstall brew...${NC}\n"
        yes | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/uninstall)"
    fi
    test -e /home/linuxbrew/.linuxbrew/bin/brew && brew purge
    sedi '/linuxbrew/d' ~/.envrc
    sedi "/${BREW_UMASK}/d" ~/.envrc
    test -d /home/linuxbrew/.linuxbrew/bin && rm -R /home/linuxbrew/.linuxbrew/bin
    test -d /home/linuxbrew/.linuxbrew/lib && rm -R /home/linuxbrew/.linuxbrew/lib
    test -d /home/linuxbrew/.linuxbrew/share && rm -R /home/linuxbrew/.linuxbrew/share
}

function uninstallBrewInOSX() {
    printf "${BLUE}[-] Uninstall brew...${NC}\n"
    yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
}

function checkBrew() {
    if hasBrewByOS; then
        printf "${GREEN}[✔] brew${NC}\n"
    else
        printf "${RED}[x] brew${NC}\n"
    fi
}

function setupBrew() {
    if hasBrewByOS; then
        printf "${GREEN}[✔] Already brew${NC}\n"
        return
    fi

    if ! hasBrewByOS; then
        if isLinux; then
            installBrewInLinux
        elif isOSX; then
            installBrewInOSX
        fi
    fi

    if ! hasBrewConfig; then
        if isLinux; then
            configBrewInLinux
        fi
    fi
}

function purgeBrew() {
    if ! hasBrewByOS; then
        return
    fi

    if isLinux; then
        uninstallBrewInLinux
        purgeBrewOS
    elif isOSX; then
        uninstallBrewInOSX
    fi
}

# Terminal colors
# Check: https://gist.github.com/vratiu/9780109
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BBLUE='\033[1;34m'


function hasCurl() {
    which curl >/dev/null && [[ "$(which curl | grep -ic "not found")" -eq "0" ]]
}

function installCurl() {
    printf "${BLUE}[-] Installing curl...${NC}\n"
    if isOSX; then
        brew install curl
    else
        sudo apt-get install --no-install-recommends curl -y
    fi
}

function uninstallCurl() {
    printf "${BLUE}[-] Uninstalling curl...${NC}\n"
    if isOSX; then
        brew uninstall curl
    else
        sudo apt-get remove --purge curl -y
    fi
}

function checkCurl() {
    if hasCurl; then
        printf "${GREEN}[✔] curl${NC}\n"
    else
        printf "${RED}[x] curl${NC}\n"
    fi
}

function setupCurl() {
    if hasCurl; then
        printf "${GREEN}[✔] Already curl${NC}\n"
        return
    fi

    installCurl
}

function purgeCurl() {
    if hasCurl; then
        uninstallCurl
    fi
}


# DNSMASQ default config
DNSMASQ_DOMAIN="dev"
DNSMASQ_HOST="127.0.0.1"

function hasDnsmasq() {
    hasBrewByOS && [[ "$(brew list | grep -ic "dnsmasq")" -eq "1" ]]
}

function installDnsmasq() {
    printf "${BLUE}[-] Installing dnsmasq...${NC}\n"
    if isOSX; then
        brew install dnsmasq
    else
        printf "${RED}[x] OS not supported yet${NC}\n"
    fi
}

function uninstallDnsmasq() {
    printf "${BLUE}[-] Uninstalling dnsmasq...${NC}\n"
    if isOSX; then
        brew uninstall dnsmasq
        sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
        sudo rm -rf /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    else
        printf "${RED}[x] OS not supported yet${NC}\n"
    fi
}

function hasDnsmasqConfig() {
    isOSX && [[ -d /usr/local/etc ]] && [[ -f /usr/local/etc/dnsmasq.conf ]] &&
        [[ -f /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist ]] &&
        [[ -d /etc/resolver ]] && [[ -f "/etc/resolver/${DNSMASQ_DOMAIN}" ]] &&
        [[ "$(cat /usr/local/etc/dnsmasq.conf | grep -ic "address=/.${DNSMASQ_DOMAIN}/${DNSMASQ_HOST}")" -eq "1" ]]
}

function purgeDnsmasqConfig() {
    sedi "/address=\/\.${DNSMASQ_DOMAIN}/d" /usr/local/etc/dnsmasq.conf
    [[ -d "/etc/resolver/${DNSMASQ_DOMAIN}" ]] && sudo rm -rf "/etc/resolver/${DNSMASQ_DOMAIN}"
}

function configDnsmasq() {
    if ! isOSX; then
        printf "${PURPLE}[-] OS not supported yet. Please configure dnsmasq manually.${NC}\n"
        return
    fi

    printf "${BLUE}[-] Configuring dnsmasq...${NC}\n"

    purgeDnsmasqConfig

    [[ ! -d /usr/local/etc ]] && mkdir -p /usr/local/etc
    echo "address=/.${DNSMASQ_DOMAIN}/${DNSMASQ_HOST}" >> /usr/local/etc/dnsmasq.conf
    sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
    sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

    [[ ! -d /etc/resolver ]] && sudo mkdir -p /etc/resolver
    echo "nameserver ${DNSMASQ_HOST}" | sudo tee -a "/etc/resolver/${DNSMASQ_DOMAIN}"
}

function checkDnsmasq() {
    if ! isOSX && [[ "${DNSMASQ_DOMAIN}" != "localhost" ]]; then
        printf "${PURPLE}[-] OS not supports yet. Please install dnsmasq manually, \"*.${DNSMASQ_DOMAIN}\".${NC}\n"
        return
    fi

    if isLinux && [[ "${DNSMASQ_DOMAIN}" = "localhost" ]]; then
        printf "${GREEN}[✔] dnsmasq \"*.${DNSMASQ_DOMAIN}\"${NC}\n"
        return
    fi

    if hasDnsmasq && hasDnsmasqConfig; then
        printf "${GREEN}[✔] dnsmasq \"*.${DNSMASQ_DOMAIN}\"${NC}\n"
    else
        printf "${RED}[x] dnsmasq \"*.${DNSMASQ_DOMAIN}\"${NC}\n"
    fi
}

function setupDnsmasq() {
    if ! isOSX && [[ "${DNSMASQ_DOMAIN}" != "localhost" ]]; then
        printf "${PURPLE}[-] OS not supports yet. Please install dnsmasq manually, \"*.${DNSMASQ_DOMAIN}\".${NC}\n"
        return
    fi

    if isLinux && [[ "${DNSMASQ_DOMAIN}" = "localhost" ]]; then
        printf "${GREEN}[✔] Already dnsmasq \"*.${DNSMASQ_DOMAIN}\"${NC}\n"
        return
    fi

    if hasDnsmasq && hasDnsmasqConfig; then
        printf "${GREEN}[✔] Already dnsmasq \"*.${DNSMASQ_DOMAIN}\"${NC}\n"
        return
    fi

    if ! hasDnsmasq; then
        installDnsmasq
    fi

    if ! hasDnsmasqConfig; then
        configDnsmasq
    fi
}

function purgeDnsmasq() {
    if ! isOSX; then
        return
    fi

    if hasDnsmasq; then
        uninstallDnsmasq
    fi

    if hasDnsmasqConfig; then
        purgeDnsmasqConfig
    fi
}


function hasDocker() {
    which docker >/dev/null && [[ "$(which docker | grep -ic "not found")" -eq "0" ]]
}

function installDocker() {
    printf "${BLUE}[-] Installing docker...${NC}\n"
    brew install docker
}

function uninstallDocker() {
    printf "${BLUE}[-] Uninstalling docker...${NC}\n"
    brew uninstall docker
}

function checkDocker() {
    if hasDocker; then
        printf "${GREEN}[✔] docker${NC}\n"
    else
        printf "${RED}[x] docker${NC}\n"
    fi
}

function setupDocker() {
    if hasDocker; then
        printf "${GREEN}[✔] Already docker${NC}\n"
        return
    fi

    installDocker
}

function purgeDocker() {
    if ! hasDocker; then
        return
    fi

    uninstallDocker
}


# GIT FLOW default config
GITFLOW_BUGFIX="fix/"
GITFLOW_FEATURE="feature/"
GITFLOW_RELEASE="release/"
GITFLOW_HOTFIX="hotfix/"
GITFLOW_SUPPORT="support/"
GITFLOW_VERSIONTAG=""
GITFLOW_MASTER="master"
GITFLOW_DEVELOP="develop"

function hasGitFlow() {
    hasBrewByOS && [[ "$(brew ls git-flow 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function installGitFlow() {
    printf "${BLUE}[-] Installing git-flow...${NC}\n"
    brew install git-flow
}

function uninstallGitFlow() {
    printf "${BLUE}[-] Uninstalling git-flow...${NC}\n"
    brew uninstall git-flow
}

function hasGitConfig() {
    [[ -f ${PROJECT_PATH}/.git/config ]]
}

function hasGitFlowConfig() {
    hasGitConfig && cat ${PROJECT_PATH}/.git/config | grep -icq "\[gitflow \"prefix\"\]" && cat ${PROJECT_PATH}/.git/config | grep -icq "\[gitflow \"branch\"\]"
}

function purgeGitFlowConfig() {
    sedi '/\[gitflow \"prefix\"\]/d' ${PROJECT_PATH}/.git/config
    sedi '/bugfix =/d' ${PROJECT_PATH}/.git/config
    sedi '/feature =/d' ${PROJECT_PATH}/.git/config
    sedi '/release =/d' ${PROJECT_PATH}/.git/config
    sedi '/hotfix =/d' ${PROJECT_PATH}/.git/config
    sedi '/support =/d' ${PROJECT_PATH}/.git/config
    sedi '/versiontag =/d' ${PROJECT_PATH}/.git/config
    sedi '/\[gitflow \"branch\"\]/d' ${PROJECT_PATH}/.git/config
    sedi '/master =/d' ${PROJECT_PATH}/.git/config
    sedi '/develop =/d' ${PROJECT_PATH}/.git/config
}

function configGitFlow() {
    printf "${BLUE}[-] Configuring git-flow...${NC}\n"

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi

    tryPrintNewLine ${PROJECT_PATH}/.git/config

    printf "[gitflow \"prefix\"]" >>${PROJECT_PATH}/.git/config
    printf "\n\tbugfix = ${GITFLOW_BUGFIX}" >>${PROJECT_PATH}/.git/config
    printf "\n\tfeature = ${GITFLOW_FEATURE}" >>${PROJECT_PATH}/.git/config
    printf "\n\trelease = ${GITFLOW_RELEASE}" >>${PROJECT_PATH}/.git/config
    printf "\n\thotfix = ${GITFLOW_HOTFIX}" >>${PROJECT_PATH}/.git/config
    printf "\n\tsupport = ${GITFLOW_SUPPORT}" >>${PROJECT_PATH}/.git/config
    printf "\n\tversiontag = ${GITFLOW_VERSIONTAG}" >>${PROJECT_PATH}/.git/config
    printf "\n[gitflow \"branch\"]" >>${PROJECT_PATH}/.git/config
    printf "\n\tmaster = ${GITFLOW_MASTER}" >>${PROJECT_PATH}/.git/config
    printf "\n\tdevelop = ${GITFLOW_DEVELOP}" >>${PROJECT_PATH}/.git/config
}

function checkGitFlow() {
    if hasGitFlow && hasGitFlowConfig; then
        printf "${GREEN}[✔] git-flow${NC}\n"
    else
        printf "${RED}[x] git-flow${NC}\n"
    fi
}

function setupGitFlow() {
    if hasGitFlow && hasGitFlowConfig; then
        printf "${GREEN}[✔] Already git-flow${NC}\n"
        return
    fi

    if ! hasGitFlow; then
        installGitFlow
    fi

    if ! hasGitFlowConfig; then
        configGitFlow
    fi
}

function purgeGitFlow() {
    if hasGitFlow; then
        uninstallGitFlow
    fi

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi
}


function hasGit() {
    which git >/dev/null && [[ "$(which git | grep -ic "not found")" -eq "0" ]]
}

function installGit() {
    printf "${BLUE}[-] Installing git...${NC}\n"
    brew install git
}

function uninstallGit() {
    printf "${BLUE}[-] Uninstalling git...${NC}\n"
    brew uninstall git
}

function checkGit() {
    if hasGit; then
        printf "${GREEN}[✔] git${NC}\n"
    else
        printf "${RED}[x] git${NC}\n"
    fi
}

function setupGit() {
    if hasGit; then
        printf "${GREEN}[✔] Already git${NC}\n"
        return
    fi

    installGit
}

function purgeGit() {
    if ! hasGit; then
        return
    fi

    uninstallGit
}


BASHRC_IMPORT="source ~/.bashrc"

function hasBashrc() {
    [[ -f ~/.bash_profile ]] && [[ "$(cat ~/.bash_profile | grep -ic "${BASHRC_IMPORT}")" -ne "0" ]]
}

function hasZshrc() {
    [[ -f ~/.zshrc ]]
}

function configBashrc() {
    tryPrintNewLine ~/.bash_profile
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >>~/.bash_profile
}

function setupBashrc() {
    if hasBashrc; then
        return
    fi

    configBashrc
}

function purgeBashrc() {
    if ! hasBashrc; then
        return
    fi

    printf "${BLUE}[-] Purging .bashrc...${NC}\n"
    sedi "/[[ -s ~/.bashrc ]] &&/d" ~/.bash_profile
}

function hasGlobalEnvrcInBash() {
    [[ -f ~/.bashrc ]] && [[ "$(cat ~/.bashrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasGlobalEnvrcInZsh() {
    [[ -f ~/.zshrc ]] && [[ "$(cat ~/.zshrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalHomeAlias() {
    [[ -f ~/.envrc ]] && [[ "$(cat ~/.envrc | grep -ic "alias @${PROJECT_NAME}")" -ne "0" ]]
}

function getLocalHomeVarName() {
    localDirName="$(getNpmPackageName ${PROJECT_PATH}/package.json)"
    localDirName=$(echo ${localDirName} | sedr 's/\-/_/g')
    localDirName=$(echo ${localDirName} | sedr 's/@//g')
    localDirName=$(echo ${localDirName} | sedr 's/\//_/g')
    localHomeName=$(echo ${localDirName} | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/')
    echo "${localHomeName}_HOME"
}

function hasLocalHome() {
    localHomeName="$(getLocalHomeVarName)"
    [[ -f ~/.envrc ]] && [[ "$(cat ~/.envrc | grep -ic "export ${localHomeName}=${PWD}")" -ne "0" ]]
}

function hasDynamicEnvrcLoader() {
    [[ -f ~/.envrc ]] && [[ "$(cat ~/.envrc | grep -ic "source ~/.envrc-dl")" -ne "0" ]]
}

function hasEnvrc() {
    hasCurl && hasBashrc && hasLocalHome && hasLocalHomeAlias && hasGlobalEnvrcInBash && hasGlobalEnvrcInZsh && hasDynamicEnvrcLoader
}

function loadEnvrc() {
    [[ -s ~/.envrc ]] && source ~/.envrc
    [[ -s ./.envrc ]] && source ./.envrc
}

function configEnvrc() {
    printf "${BLUE}[-] Configuring .envrc...${NC}\n"

    if ! hasBashrc; then
        setupBashrc
    fi

    if ! hasLocalHome; then
        tryPrintNewLine ~/.envrc
        localHomeName="$(getLocalHomeVarName)"
        echo "export ${localHomeName}=${PWD}" >>~/.envrc
        export ${localHomeName}=${PWD}
        printf "${GREEN}[✔] Set: local home${NC}\n"
    fi

    if ! hasLocalHomeAlias; then
        tryPrintNewLine ~/.envrc
        echo "alias @${PROJECT_NAME}=\"cd \${${localHomeName}}\"" >>~/.envrc
        eval "alias @${PROJECT_NAME}=\"cd \${${localHomeName}}\""
        printf "${GREEN}[✔] Set: local home alias${NC}\n"
    fi

    if ! hasGlobalEnvrcInBash; then
        tryPrintNewLine ~/.bashrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.bashrc
        loadEnvrc
        printf "${GREEN}[✔] Set: global .envrc in bash${NC}\n"
    fi

    if ! hasGlobalEnvrcInZsh; then
        tryPrintNewLine ~/.zshrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.zshrc
        loadEnvrc
        printf "${GREEN}[✔] Set: global .envrc in zsh${NC}\n"
    fi

    sedi "/.envrc-dl/d" ~/.envrc
    tryPrintNewLine ~/.envrc
    echo "[[ -s ~/.envrc-dl ]] && source ~/.envrc-dl" >>~/.envrc
    source ~/.envrc-dl
    printf "${GREEN}[✔] Set: dynamic .envrc loader${NC}\n"
}

function setupEnvrc() {
    if ! hasCurl; then
        setupCurl
    fi

    # ensure the dynamic loader is always updated to latest
    ENVRC_DYNAMIC_LOADER="$(curl -s https://raw.githubusercontent.com/freak2geek/environment-helpers/master/helpers/envrc-dynamic-loader.sh)"
    [[ -f ~/.envrc-dl ]] && rm ~/.envrc-dl
    echo "${ENVRC_DYNAMIC_LOADER}" >>~/.envrc-dl

    if hasEnvrc; then
        printf "${GREEN}[✔] Already .envrc${NC}\n"
        return
    fi

    OLD_PWD=${PWD}
    cd ${PROJECT_PATH}
    configEnvrc
    cd ${OLD_PWD}
}

function checkEnvrc() {
    OLD_PWD=${PWD}
    cd ${PROJECT_PATH}
    if hasEnvrc; then
        printf "${GREEN}[✔] .envrc${NC}\n"
    else
        printf "${RED}[x] .envrc${NC}\n"
    fi
    cd ${OLD_PWD}
}

function purgeEnvrc() {
    if ! hasEnvrc; then
        return
    fi
    localHomeName="$(getLocalHomeVarName)"

    printf "${BLUE}[-] Purging .envrc...${NC}\n"
    sedi "/envrc/d" ~/.bashrc
    sedi "/envrc/d" ~/.zshrc
    sedi "/export ${localHomeName}/d" ~/.envrc
    sedi "/alias @${PROJECT_NAME}/d" ~/.envrc
    sedi "/alias @old-pwd/d" ~/.envrc
}

function endsWithNewLine() {
    [[ -f $1 ]] && test "$(tail -c 1 "$1" | wc -l)" -ne 0
}

function tryPrintNewLine() {
    fileToPrint=${1-}
    if ! endsWithNewLine ${fileToPrint}; then
        printf "\n" >> ${fileToPrint}
    fi
}

VISUDO_NOPASSWD="${USER} ALL=(ALL) NOPASSWD: ALL"

function hasSudoNoPasswd() {
    [[ $(sudo cat /etc/sudoers | grep -ic "${VISUDO_NOPASSWD}") -ne "0" ]]
}

function configSudoNoPasswd() {
    printf "${BLUE}[-] Configuring sudo nopasswd...${NC}\n"
    echo "${VISUDO_NOPASSWD}" | sudo EDITOR='tee -a' visudo
}

function checkSudoNoPasswd() {
    if hasSudoNoPasswd; then
        printf "${GREEN}[✔] sudo nopasswd${NC}\n"
    else
        printf "${RED}[x] sudo nopasswd${NC}\n"
    fi
}

function setupSudoNoPasswd() {
    if hasSudoNoPasswd; then
        printf "${GREEN}[✔] Already sudo nopasswd${NC}\n"
        return
    fi

    configSudoNoPasswd
}

function purgeSudoNoPasswd() {
    if ! hasSudoNoPasswd; then
        return
    fi
    printf "${BLUE}[-] Purging sudo nopasswd...${NC}\n"
    sudoSedi "/${VISUDO_NOPASSWD}/d" /etc/sudoers
}

function isOSX() {
    [[ "$OSTYPE" == "darwin"* ]]
}

function isLinux() {
    [[ "$OSTYPE" == "linux-gnu" ]]
}

function sedi() {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}

function sedr() {
    if isOSX; then
        sed -E -- "$@"
    else
        sed -r -- "$@"
    fi
}

function sudoSedi() {
    sed --version >/dev/null 2>&1 && sudo sed -i -- "$@" || sudo sed -i "" "$@"
}

function killProcessByPort() {
    portToKill=${1-''}
    portPid="$(pgrep -f ${portToKill})"

    if [[ ${portPid} -eq '' ]]; then
        return
    fi

    sudo kill -9 ${portPid}
}

function loadEnv {
  if [[ -f $1 ]] ; then
    while read -r line
    do
      [[ -z "$line" ]] && continue
      eval "export ${line}"
    done < "$1"
  fi
}

function printEnv() {
    file=${1-}
    prefix=${2-}
    if [[ -f ${file} ]] ; then
        while read -r line
        do
            [[ -z "$line" ]] && continue
            parsedLine="$(eval "echo "$(echo ${line})"")"
            printf "${PURPLE}${prefix}${parsedLine}${NC}\n"
        done < "${file}"
    fi
}

ENV_OVERRIDE_FILENAME=".env.override"

function setOverride() {
    override=${1-}
    unsetOverride ${override}
    tryPrintNewLine "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
    echo "${override}" >> "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}

function unsetOverride() {
    if [[ ! -f "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}" ]]; then
        return
    fi
    override=${1-}
    sedi "/${override}/d" "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}

function loadOverrides() {
    [[ -f "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}" ]] && loadEnv "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}

function cleanOverrides() {
    rm -f "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
    touch "${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
}

function printOverrides() {
    prefix=${1-}
    envOverridePath="${PROJECT_PATH}/${ENV_OVERRIDE_FILENAME}"
    printEnv ${envOverridePath} ${prefix}
}


function hasIfconfig() {
    which ifconfig >/dev/null && [[ "$(which ifconfig | grep -ic "not found")" -eq "0" ]]
}

function installIfconfig() {
    printf "${BLUE}[-] Installing ifconfig...${NC}\n"
    if isLinux; then
        sudo apt-get install --no-install-recommends net-tools -y
    fi
}

function checkIfconfig() {
    if hasIfconfig; then
        printf "${GREEN}[✔] ifconfig${NC}\n"
    else
        printf "${RED}[x] ifconfig${NC}\n"
    fi
}

function setupIfconfig() {
    if hasIfconfig; then
        printf "${GREEN}[✔] Already ifconfig${NC}\n"
        return
    fi

    installIfconfig
}

function getLocalIp() {
    if isOSX; then
        echo "$(ifconfig | grep '\<inet\>' | cut -d ' ' -f2 | grep -v '127.0.0.1')"
        return
    elif isLinux; then
        echo "$(ifconfig | grep "inet" | awk '{print $2}' | cut -d/ -f1 | head -n 1)"
        return
    fi
}



function hasRuby() {
    isOSX && [[ "$(brew ls ruby 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function hasXcode() {
    [[ "$(xcode-select -p | grep -ic "not found")" -eq "0" ]] && [[ -d /Applications/Xcode.app ]]
}

function hasCocoapods() {
    [[ "$(gem list | grep -ic "cocoapods")" -ne "0" ]]
}

function hasIos() {
    isOSX && hasXcode && hasCocoapods
}

function installRuby() {
    printf "${BLUE}[-] Installing xcode...${NC}\n"
    brew install ruby
}

function installXcode() {
    printf "${BLUE}[-] Installing xcode...${NC}\n"
    brew install mas
    mas install 497799835
}

function configXcode() {
    sudo xcodebuild -license accept
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
}

function installCocoapods() {
    printf "${BLUE}[-] Installing cocoapods...${NC}\n"
    if ! hasRuby; then
        installRuby
    fi

    sudo gem install cocoapods
    pod setup
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

    printf "${BLUE}[-] Setting up ios...${NC}\n"

    if ! hasXcode; then
        installXcode
    fi

    configXcode

    if ! hasCocoapods; then
        installCocoapods
    fi
}

function purgeIos() {
    if ! isOSX; then
        return
    fi

    if ! hasIos; then
        return
    fi

    printf "${BLUE}[-] Purging ios...${NC}\n"

    uninstallXcode
    uninstallCocoapods
}


function hasMeteorConcurrently() {
    hasMeteor && hasLibForCurrentMeteor concurrently
}

function installMeteorConcurrently() {
    installMeteorLib concurrently
}

function uninstallMeteorConcurrently() {
    uninstallMeteorLib concurrently
}

function checkMeteorConcurrently() {
    checkMeteorLib concurrently
}

function setupMeteorConcurrently() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib concurrently; then
        printf "${GREEN}[✔] Already meteor concurrently${NC}\n"
        return
    fi

    if ! hasMeteorLib concurrently; then
        installMeteorConcurrently
    fi
}

function purgeMeteorConcurrently() {
    if ! hasMeteorLib concurrently; then
        return
    fi

    uninstallMeteorConcurrently
}


function hasMeteorLerna() {
    hasMeteor && hasLibForCurrentMeteor lerna
}

function installMeteorLerna() {
    installMeteorLib lerna
}

function uninstallMeteorLerna() {
    uninstallMeteorLib lerna
}

function checkMeteorLerna() {
    checkMeteorLib lerna
}

function setupMeteorLerna() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib lerna; then
        printf "${GREEN}[✔] Already meteor lerna${NC}\n"
        return
    fi

    if ! hasMeteorLib lerna; then
        installMeteorLerna
    fi
}

function purgeMeteorLerna() {
    if ! hasMeteorLib lerna; then
        return
    fi

    uninstallMeteorLerna
}

function setupLernaProject() {
    printf "${BLUE}[-] Installing \"${PROJECT_NAME}\" project...${NC}\n"
    meteor lerna bootstrap $@
}

function cleanLernaProject() {
    printf "${BLUE}[-] Cleaning \"${PROJECT_NAME}\" project...${NC}\n"
    rm -rf ./node_modules
}


# MONGO default config
MONGO_VERSION="stable"
MONGO_CONF="/etc/mongodb.conf"
MONGO_DBPATH="/data/db"
MONGO_LOGPATH="/var/log/mongod.log"
MONGO_PORT=27017
MONGO_REPLICA="rs0"
MONGO_R1_DBPATH="/data/db-rs0-0"
MONGO_R2_DBPATH="/data/db-rs0-1"
MONGO_R1_LOGPATH="/var/log/mongod-rs0-0.log"
MONGO_R2_LOGPATH="/var/log/mongod-rs0-1.log"
MONGO_R1_PORT=27018
MONGO_R2_PORT=27019

function hasMeteorM() {
   hasMeteor && hasLibForCurrentMeteor m
}

function installMeteorM() {
    prepareMeteorM
    installMeteorLib m
}

function uninstallMeteorM() {
    sudo rm -rf /usr/local/m/versions
    uninstallMeteorLib m
}

function prepareMeteorM() {
    sudo mkdir -p /usr/local/m/versions
    sudo chmod -R 777 /usr/local/m
}

function checkMeteorM() {
    checkMeteorLib m
}

function setupMeteorM() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib m; then
        printf "${GREEN}[✔] Already meteor m${NC}\n"
        return
    fi

    installMeteorM
}

function purgeMeteorM() {
    if ! hasMeteorLib m; then
        return
    fi

    uninstallMeteorM
}

function hasMongo() {
    hasMeteorM && meteor m | grep -icq "ο.*${MONGO_VERSION}"
}

function installMongo() {
    if hasMongo; then
        printf "${GREEN}[✔] Already mongo@${MONGO_VERSION}${NC}\n"
        return;
    fi
    printf "${BLUE}[-] Installing mongo@${MONGO_VERSION}...${NC}\n"
    yes | sudo meteor m ${MONGO_VERSION}
}

function uninstallMongo() {
    printf "${BLUE}[-] Uninstalling mongo@${MONGO_VERSION}...${NC}\n"
    yes | sudo meteor m rm ${MONGO_VERSION}
}

function getReplicaFile() {
    file=${1-''}
    replica=${2-'0'}
    echo $file | sed -r -e "s/(^\/.*\/)(.*(\..*)|.*)/\1rs0-${MONGO_REPLICA}\3/"
}

function hasMongoConfig() {
    [[ -f ${MONGO_CONF} ]] && [[ -d  ${MONGO_DBPATH} ]] && [[ -f ${MONGO_LOGPATH} ]]
}

function configMongo() {
    if hasMongoConfig; then
        printf "${GREEN}[✔] Already mongo.conf \"${MONGO_CONF}\"${NC}\n"
        printf "${GREEN}[✔] Already dbpath \"${MONGO_DBPATH}\"${NC}\n"
        printf "${GREEN}[✔] Already logpath \"${MONGO_LOGPATH}\"${NC}\n"
        return
    fi

    printf "${BLUE}[-] Configuring mongoConf \"${MONGO_CONF}\"...${NC}\n"
    sudo touch ${MONGO_CONF}
    printf "${BLUE}[-] Configuring dbpath \"${MONGO_DBPATH}\"...${NC}\n"
    sudo mkdir -p ${MONGO_DBPATH}
    printf "${BLUE}[-] Configuring logpath \"${MONGO_LOGPATH}\"...${NC}\n"
    sudo touch ${MONGO_LOGPATH}
}

function checkMongo() {
    if hasMongo && hasMongoConfig; then
        printf "${GREEN}[✔] meteor mongo ${MONGO_VERSION}${NC}\n"
    else
        printf "${RED}[x] meteor mongo ${MONGO_VERSION}${NC}\n"
    fi
}

function setupMongo() {
    if ! hasMeteorLib m; then
        setupMeteorM
    fi
    installMongo
    configMongo
}

function purgeMongo() {
    uninstallMongo

    sudo rm ${MONGO_CONF}
    sudo rm -R ${MONGO_DBPATH}
    sudo rm ${MONGO_LOGPATH}
}

function isRunningMongo() {
    ps -edaf | grep -icq "\-\-port ${MONGO_PORT}"
}

function startMongo() {
    if ! hasMongo; then
        return
    fi

    if isRunningMongo; then
        printf "${GREEN}[✔] Already running mongo \"${MONGO_VERSION}\"${NC}\n"
        return
    fi

    printf "${BLUE}[-] Starting to mongo \"${MONGO_VERSION}\"...${NC}\n"
    sudo meteor m use ${MONGO_VERSION} --port ${MONGO_PORT} --dbpath ${MONGO_DBPATH} --fork --logpath ${MONGO_LOGPATH} --journal

    while ! nc -z localhost ${MONGO_PORT} </dev/null; do sleep 1; done

    if isRunningMongo; then
        printf "${GREEN}[✔] Already running mongo \"${MONGO_VERSION}\"${NC}\n"
    else
        printf "${RED}[x] An error running mongo \"${MONGO_VERSION}\"${NC}\n"
    fi
}

function shutdownMongo() {
    printf "${BLUE}[-] Shutting down to mongo \"${MONGO_VERSION}\"...${NC}\n"

    if ! hasMongo; then
        return
    fi

    meteor m mongo ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('admin').shutdownServer()" 1> /dev/null

    if ! isRunningMongo; then
        printf "${GREEN}[✔] Already stopped mongo \"${MONGO_VERSION}\"${NC}\n"
    else
        printf "${RED}[x] An error stopping mongo \"${MONGO_VERSION}\"${NC}\n"
    fi
}

function killMongo() {
    printf "${BLUE}[-] Killing mongo...${NC}\n"
    killProcessByPort ${MONGO_PORT}
}

function hasReplicaOneDBConfig() {
    [[ -d ${MONGO_R1_DBPATH} ]]
}

function hasReplicaTwoDBConfig() {
    [[ -d ${MONGO_R2_DBPATH} ]]
}

function hasReplicaOneLogsConfig() {
    [[ -f ${MONGO_R1_LOGPATH} ]]
}

function hasReplicaTwoLogsConfig() {
    [[ -f ${MONGO_R2_LOGPATH} ]]
}

function hasOplogConf() {
    meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "rs.conf()" | grep -icq "\"_id\" : \"rs0\""
}

function hasOplogInitialized() {
    meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('local').getCollection('system.replset').findOne({\"_id\":\"${MONGO_REPLICA}\"})" | grep -icq "\"_id\" : \"rs0\""
}

function hasOplogUser() {
    meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('admin').getCollection('system.users').findOne({\"user\":\"oplogger\"})" | grep -icq "\"user\" : \"oplogger\""
}

function hasOlogConfig() {
    hasMongo && hasMongoConfig && hasReplicaOneDBConfig && hasReplicaTwoDBConfig &&
    hasReplicaOneLogsConfig && hasReplicaTwoLogsConfig && hasOplogInitialized && hasOplogUser
}

function hasMongoConnected() {
    ps -aux | grep -ic "$(meteor m bin ${MONGO_VERSION})"
}

function isRunningMongoAndReplicas() {
    isRunningMongo &&
        ps -edaf | grep -icq "\-\-port ${MONGO_R1_PORT}" &&
        ps -edaf | grep -icq "\-\-port ${MONGO_R2_PORT}"
}

function startMongoAndReplicas() {
    if isRunningMongoAndReplicas; then
        printf "${GREEN}[✔] Already running mongo \"${MONGO_VERSION}\" and replicas${NC}\n"
        return
    fi

    printf "${BLUE}[-] Starting to mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port ${MONGO_PORT} --dbpath ${MONGO_DBPATH} --fork --logpath ${MONGO_LOGPATH} --replSet ${MONGO_REPLICA} --journal
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port ${MONGO_R1_PORT} --dbpath ${MONGO_R1_DBPATH} --fork --logpath ${MONGO_R1_LOGPATH} --replSet ${MONGO_REPLICA} --journal
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port ${MONGO_R2_PORT} --dbpath ${MONGO_R2_DBPATH} --fork --logpath ${MONGO_R2_LOGPATH} --replSet ${MONGO_REPLICA} --journal

    while ! nc -z localhost ${MONGO_PORT} </dev/null; do sleep 1; done
    while ! nc -z localhost ${MONGO_R1_PORT} </dev/null; do sleep 1; done
    while ! nc -z localhost ${MONGO_R2_PORT} </dev/null; do sleep 1; done

    if isRunningMongoAndReplicas; then
        printf "${GREEN}[✔] Already running mongo \"${MONGO_VERSION}\" and replicas${NC}\n"
    else
        printf "${RED}[x] An error running mongo \"${MONGO_VERSION}\" and replicas${NC}\n"
    fi
}

function shutdownMongoAndReplicas() {
    printf "${BLUE}[-] Shutting down to mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

    meteor m mongo ${MONGO_VERSION} --port ${MONGO_R1_PORT} --eval "db.getSiblingDB('admin').shutdownServer()" 1> /dev/null
    meteor m mongo ${MONGO_VERSION} --port ${MONGO_R2_PORT} --eval "db.getSiblingDB('admin').shutdownServer()" 1> /dev/null
    meteor m mongo ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('admin').shutdownServer()" 1> /dev/null

    if ! isRunningMongo; then
        printf "${GREEN}[✔] Already stopped mongo \"${MONGO_VERSION}\" and replicas${NC}\n"
    else
        printf "${RED}[x] An error stopping mongo \"${MONGO_VERSION}\" and replicas${NC}\n"
    fi
}

function killMongoAndReplicas() {
    printf "${BLUE}[-] Killing mongo and replicas...${NC}\n"
    killProcessByPort ${MONGO_PORT}
    killProcessByPort ${MONGO_R1_PORT}
    killProcessByPort ${MONGO_R2_PORT}
}

function repairMongoAndReplicas() {
    printf "${BLUE}[-] Repairing mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port ${MONGO_PORT} --dbpath ${MONGO_DBPATH} --repair
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port ${MONGO_R1_PORT} --dbpath ${MONGO_R1_DBPATH} --repair
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port ${MONGO_R2_PORT} --dbpath ${MONGO_R2_DBPATH} --repair
}

function checkMongoOplog() {
    if ! hasMongo || ! hasMongoConfig; then
        printf "${RED}[x] meteor mongo oplog${NC}\n"
        return
    fi

    isMongoConnected=0
    if isRunningMongoAndReplicas; then
        isMongoConnected=1
    fi

    if [[ ${isMongoConnected} -eq 0 ]]; then
        startMongo 1>/dev/null
    fi
    if hasOlogConfig; then
        printf "${GREEN}[✔] meteor mongo oplog${NC}\n"
    else
        printf "${RED}[x] meteor mongo oplog${NC}\n"
    fi
    if [[ ${isMongoConnected} -eq 0 ]]; then
        shutdownMongo 1>/dev/null
    fi
}

function setupMongoOplog() {
    configMongo

    if hasReplicaOneDBConfig; then
        printf "${GREEN}[✔] Already dbReplicaOne \"${MONGO_R1_DBPATH}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring dbReplicaOne \"${MONGO_R1_DBPATH}\"...${NC}\n"
        sudo mkdir -p ${MONGO_R1_DBPATH}
        sudo chmod -R 777 ${MONGO_R1_DBPATH}
    fi

    if hasReplicaTwoDBConfig; then
        printf "${GREEN}[✔] Already dbReplicaTwo \"${MONGO_R2_DBPATH}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring dbReplicaTwo \"${MONGO_R2_DBPATH}\"...${NC}\n"
        sudo mkdir -p ${MONGO_R2_DBPATH}
        sudo chmod -R 777 ${MONGO_R2_DBPATH}
    fi

    if hasReplicaOneLogsConfig; then
        printf "${GREEN}[✔] Already logReplicaOne \"${MONGO_R1_LOGPATH}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring logReplicaOne \"${MONGO_R1_LOGPATH}\"...${NC}\n"
        # [[ ! -d  "$(dirname -- ${MONGO_R1_LOGPATH})" ]] && sudo mkdir -p -- "$(dirname -- ${MONGO_R1_LOGPATH})"
        sudo touch ${MONGO_R1_LOGPATH}
    fi

    if hasReplicaTwoLogsConfig; then
        printf "${GREEN}[✔] Already logReplicaTwo \"${MONGO_R2_LOGPATH}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring logReplicaTwo \"${MONGO_R2_LOGPATH}\"...${NC}\n"
        sudo touch ${MONGO_R2_LOGPATH}
    fi

    isMongoConnected=0
    if isRunningMongoAndReplicas; then
        isMongoConnected=1
    fi

    if [[ ${isMongoConnected} -eq 0 ]]; then
        startMongoAndReplicas
    fi
    if hasOplogInitialized; then
        printf "${GREEN}[✔] Already oplog initialized${NC}\n"
    else
        OPLOG_CONFIG="{\"_id\":\"${MONGO_REPLICA}\",\"members\":[{\"_id\":0,\"host\":\"127.0.0.1:${MONGO_PORT}\",\"priority\":1},{\"_id\":1,\"host\":\"127.0.0.1:${MONGO_R1_PORT}\",\"priority\":0},{\"_id\":2,\"host\":\"127.0.0.1:${MONGO_R2_PORT}\",\"priority\":0}]}"
        if hasOplogConf; then
            meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "rs.reconfig(${OPLOG_CONFIG})"
        else
            meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "rs.initiate(${OPLOG_CONFIG})"
        fi
    fi
    if [[ ${isMongoConnected} -eq 0 ]]; then
        shutdownMongoAndReplicas 1>/dev/null
    fi

    if isRunningMongo; then
        isMongoConnected=1
    fi

    if [[ ${isMongoConnected} -eq 0 ]]; then
        startMongo
    fi
    if hasOplogUser; then
        printf "${GREEN}[✔] Already oplog user${NC}\n"
    else

        meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('admin').createUser({\"user\":\"oplogger\",\"pwd\":\"PASSWORD\",\"roles\":[{\"role\":\"read\",\"db\":\"local\"}],\"passwordDigestor\":\"server\"})"
    fi
    if [[ ${isMongoConnected} -eq 0 ]]; then
        shutdownMongo 1>/dev/null
    fi
}

function purgeMongoOplog() {
    printf "${BLUE}[-] Purging oplog...${NC}\n"

    wasConnected=$(hasMongoConnected)
    if [[ ${wasConnected} -eq 0 ]]; then
        startMongo
    fi

    if hasOplogUser; then
        meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('admin').getCollection('system.users').deleteOne({\"user\":\"oplogger\"})"
    fi

    if hasOplogInitialized; then
        meteor m shell ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('local').getCollection('system.replset').deleteOne({\"_id\":\"rs0\"})"
    fi

    if [[ ${wasConnected} -eq 0 ]]; then
        shutdownMongo
    fi

    if hasReplicaOneDBConfig; then
        sudo rm -rf ${MONGO_R1_DBPATH}
    fi

    if hasReplicaTwoDBConfig; then
        sudo rm -rf ${MONGO_R2_DBPATH}
    fi

    if hasReplicaOneLogsConfig; then
        sudo rm ${MONGO_R1_LOGPATH}
    fi

    if hasReplicaTwoLogsConfig; then
        sudo rm ${MONGO_R2_LOGPATH}
    fi
}

MONGO_OUT_DIR='dump'
MONGO_HOST='localhost'
MONGO_DB='config'

function copyMongoDb() {
    printf "${BLUE}[-] Copying db..${NC}\n"
    printf "${PURPLE} - Host: ${MONGO_HOST}${NC}\n"
    printf "${PURPLE} - Port: ${MONGO_PORT}${NC}\n"
    printf "${PURPLE} - DB: ${MONGO_DB}${NC}\n"
    printf "${PURPLE} - Out: ${MONGO_OUT_DIR}${NC}\n"
    printf "${PURPLE} - Options: ${MONGO_OPTIONS}${NC}\n"

    rm -rf ${MONGO_DB_OUT}/${MONGO_DB}
    "$(meteor m bin ${MONGO_VERSION})/mongodump" --host ${MONGO_HOST} --port ${MONGO_PORT} --db ${MONGO_DB} --out ${MONGO_OUT_DIR} ${MONGO_OPTIONS}
}

function restoreMongoDb() {
    printf "${BLUE}[-] Restoring db..${NC}\n"
    printf "${PURPLE} - Host: ${MONGO_HOST}${NC}\n"
    printf "${PURPLE} - Port: ${MONGO_PORT}${NC}\n"
    printf "${PURPLE} - DB copied: ${MONGO_OUT_DIR}/${MONGO_DB_COPIED}${NC}\n"
    printf "${PURPLE} - DB to restore: ${MONGO_DB}${NC}\n"
    printf "${PURPLE} - Options: ${MONGO_OPTIONS}${NC}\n"

    "$(meteor m bin ${MONGO_VERSION})/mongorestore" --host ${MONGO_HOST} --port ${MONGO_PORT} --dir ${MONGO_OUT_DIR}/${MONGO_DB_COPIED} --db ${MONGO_DB} ${MONGO_OPTIONS}
}

function restoreMongoDbSchema() {
    schemaDb="${MONGO_OUT_DIR}/${MONGO_DB}-schema"
    printf "${BLUE}[-] Restoring db schema..${NC}\n"
    printf "${PURPLE} - Host: ${MONGO_HOST}${NC}\n"
    printf "${PURPLE} - Port: ${MONGO_PORT}${NC}\n"
    printf "${PURPLE} - DB copied: ${MONGO_OUT_DIR}/${MONGO_DB_COPIED}${NC}\n"
    printf "${PURPLE} - DB schema: ${schemaDb}${NC}\n"
    printf "${PURPLE} - DB to restore schema: ${MONGO_DB}${NC}\n"
    printf "${PURPLE} - Options: ${MONGO_OPTIONS}${NC}\n"

    mkdir -p "${schemaDb}"
    find "${MONGO_OUT_DIR}/${MONGO_DB_COPIED}" -name '*metadata*' -type f -exec cp {} ${schemaDb} \;

    "$(meteor m bin ${MONGO_VERSION})/mongorestore" --host ${MONGO_HOST} --port ${MONGO_PORT} --dir ${schemaDb} --db ${MONGO_DB} ${MONGO_OPTIONS}
}


function hasMeteorRollup() {
    hasMeteor && hasLibForCurrentMeteor rollup
}

function installMeteorRollup() {
    installMeteorLib rollup
}

function uninstallMeteorRollup() {
    uninstallMeteorLib rollup
}

function checkMeteorRollup() {
    checkMeteorLib rollup
}

function setupMeteorRollup() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLib rollup; then
        printf "${GREEN}[✔] Already meteor rollup${NC}\n"
        return
    fi

    if ! hasMeteorLib rollup; then
        installMeteorRollup
    fi
}

function purgeMeteorRollup() {
    if ! hasMeteorLib rollup; then
        return
    fi

    uninstallMeteorRollup
}


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
        [[ -d ~/.npm ]] && sudo chmod -R 777 ~/.npm
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

    meteorOptions=${@:2}
    if [[ ! -z ${meteorOptions} ]]; then
        printf "${PURPLE} - Options: ${meteorOptions}${NC}\n"
    fi

    trap "killMeteorApp ${APP_TO} && cd ${oldPWD}" SIGINT SIGTERM
    meteor run ${DEVICES_TO} --settings ${meteorSettingsPath} --port ${PORT} ${meteorOptions}
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

function cleanMeteorMobileApp() {
    APP_TO=${1-${APP_TO}}
    printf "${BLUE}[-] Cleaning \"${APP_TO}\" meteor mobile app...${NC}\n"
    oldPWD=${PWD}
    cd ${PROJECT_PATH}/${APPS_PATH}/${APP_TO}
    rm -rf ./.meteor/local/cordova-build
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

function getNpmPackageName() {
    packagePath=${1-'package.json'}
    [[ -f ${packagePath} ]] && cat ${packagePath} | grep name | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]'
}

function getNpmPackageVersion() {
    packagePath=${1-'package.json'}
    [[ -f ${packagePath} ]] && cat ${packagePath} | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]'
}


PROJECT_PATH=${PROJECT_PATH:-'.'}

ENV_DEVELOPMENT='development'
ENV_PRODUCTION='production'

function bootProject() {
    PROJECT_NAME=$(getNpmPackageName ${PROJECT_PATH}/package.json)
    PROJECT_VERSION=$(getNpmPackageVersion ${PROJECT_PATH}/package.json)

    if [[ -d ${PROJECT_PATH}/${APPS_PATH} ]]; then
        for dir in `find ${PROJECT_PATH}/${APPS_PATH} -maxdepth 1 -type d`
        do
            if [[ -f ${dir}/package.json ]]; then
                packageName=$(getNpmPackageName ${dir}/package.json)
                packageVersion=$(getNpmPackageVersion ${dir}/package.json)
                localPackageName=$(echo ${packageName} | sedr 's/\-/_/g')
                localPackageName=$(echo ${localPackageName} | sedr 's/@//g')
                localPackageName=$(echo ${localPackageName} | sedr 's/\//_/g')
                localPackageName=$(echo ${localPackageName} | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/')
                eval "${localPackageName}_NAME=\"${packageName}\""
                eval "${localPackageName}_VERSION=\"${packageVersion}\""
                eval "${localPackageName}_APP=\"$(basename ${packageName})\""
                eval "${localPackageName}_PATH=\"${dir}\""
            fi
        done
    fi
}


function hasRvm() {
    which rvm >/dev/null && [[ "$(which rvm | grep -ic "not found")" -eq "0" ]]
}

function hasRuby() {
    which ruby >/dev/null && [[ "$(which ruby | grep -ic "not found")" -eq "0" ]]
}

function installRvm() {
    if ! hasCurl; then
        setupCurl
    fi

    configEnvrc

    printf "${BLUE}[-] Installing rvm...${NC}\n"
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
}

function uninstallRvm() {
    printf "${BLUE}[-] Uninstalling rvm...${NC}\n"
    rm -rf ~/.rvm
    sedi '/\.rvm\/bin/d' ~/.envrc
    sedi '/\.rvm\//d' ~/.bash_profile
}

function installRuby() {
    version=${1-'2.5.0'}

    if ! hasRvm; then
        installRvm
    fi

    printf "${BLUE}[-] Installing ruby ${version}...${NC}\n"
    rvm install ${version}
    rvm --default use ${version}
}

function uninstallRuby() {
    uninstallRvm
}


function hasCodeInsiders() {
    which code-insiders >/dev/null && [[ "$(which code-insiders | grep -ic "not found")" -eq "0" ]]
}

function installCodeInsiders() {
    printf "${BLUE}[-] Installing code-insiders...${NC}\n"
    if isOSX; then
        brew tap homebrew/cask-versions
        brew cask install visual-studio-code-insiders
    else
        sudo apt-get install snapd -y
        sudo snap install code-insiders --classic
    fi
}

function uninstallCodeInsiders() {
    printf "${BLUE}[-] Uninstalling code-insiders...${NC}\n"
    if isOSX; then
        $(which code-insiders) --uninstall-extension shan.code-settings-sync
        brew cask uninstall visual-studio-code-insiders
    else
        sudo snap remove code-insiders
    fi
}

function runCodeInsiders() {
    workspaceFile=$(find . -type f -iname "*.code-workspace")
    fileToOpen=${workspaceFile-"."}
    $(which code-insiders) ${fileToOpen}
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
    hasCodeInsiders && [[ "$($(which code-insiders) --list-extensions | grep -ic "shan.code-settings-sync")" -eq "1" ]] &&
        [[ -f "$(getSyncPluginConfigPath)" ]] && [[ "$(cat "$(getSyncPluginConfigPath)" | grep -ic "\"downloadPublicGist\":true")" -eq "1" ]]
}

function configCodeInsiders() {
    printf "${BLUE}[-] Configuring code-insiders...${NC}\n"

    $(which code-insiders) --install-extension shan.code-settings-sync

    if isOSX; then
        brew install jq
    elif isLinux; then
        sudo add-apt-repository universe
        sudo apt-get update
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


function hasZsh() {
    hasBrewByOS && [[ "$(brew ls zsh 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function hasOhMyZsh() {
    hasCurl && [[ -d "${HOME}/.oh-my-zsh" ]]
}

function hasZshrc() {
    hasCurl && [[ -f "${HOME}/.oh-my-zsh/custom/plugins/zshrc/zshrc.plugin.zsh" ]]
}

function hasZshAndOhMyZsh() {
    hasZsh && hasOhMyZsh
}

function hasZshAsDefault() {
  [[ $(cat ~/.bashrc | grep -ic 'export SHELL=$(which zsh)') -ne "0" ]]
}

function installZsh() {
   printf "${BLUE}[-] Installing zsh...${NC}\n"
   brew install zsh
}

function uninstallZsh() {
   printf "${BLUE}[-] Uninstalling zsh...${NC}\n"
   brew uninstall zsh
}

function installOhMyZsh() {
    if ! hasCurl; then
        setupCurl
    fi
    printf "${BLUE}[-] Installing zsh...${NC}\n"
    yes | curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
}

function uninstallOhMyZsh() {
    printf "${BLUE}[-] Uninstalling OhMyZsh...${NC}\n"
    rm -rf "${HOME}/.oh-my-zsh"
}

function installZshrc() {
    if ! hasCurl; then
        setupCurl
    fi
    printf "${BLUE}[-] Installing zshrc...${NC}\n"
    yes | curl -sSL https://raw.githubusercontent.com/freak2geek/zshrc/master/install.sh | bash
}

function checkZsh() {
    if hasZshAndOhMyZsh; then
        printf "${GREEN}[✔] zsh${NC}\n"
    else
        printf "${RED}[x] zsh${NC}\n"
    fi
}

function setupZsh() {
    if hasZshAndOhMyZsh; then
        printf "${GREEN}[✔] Already zsh${NC}\n"
        return
    fi

    if ! hasZsh; then
        installZsh
    fi

    if ! hasOhMyZsh; then
        installOhMyZsh
    fi

    setupEnvrc
}

function disableZshAsDefault() {
    printf "${BLUE}[-] Disabling zsh...${NC}\n"
    sedi '/which zsh/d' ~/.bashrc
    sedi '/exec "$SHELL"/d' ~/.bashrc
    export SHELL=$(which bash)
    [[ -s "$SHELL" ]] && exec "$SHELL" -l
}

function purgeZsh() {
    if hasZsh; then
        uninstallZsh
    fi

    if hasOhMyZsh; then
        uninstallOhMyZsh
    fi

    if hasZshAsDefault; then
        disableZshAsDefault
    fi
}

function configZshAsDefault() {
    if hasZshAsDefault; then
        printf "${GREEN}[✔] Already zsh as default${NC}\n"
        return
    fi

    setupEnvrc

    printf "${BLUE}[-] Setting zsh as default shell...${NC}\n"
    tryPrintNewLine ~/.bashrc
    echo 'export SHELL=$(which zsh)' >>~/.bashrc
    echo '[[ -s "$SHELL" ]] && exec "$SHELL" -l' >>~/.bashrc
    [[ -s "$SHELL" ]] && exec "$SHELL" -l
    # Alternative method
    # if [[ $(cat /etc/shells | grep -ic "$(which zsh)") -eq "0" ]]; then
    #    which zsh | sudo tee -a /etc/shells
    # fi
    # chsh -s $(which zsh)
}
