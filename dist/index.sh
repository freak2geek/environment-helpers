#!/usr/bin/env bash
ENVRC_DYNAMIC_LOADER="$(curl -s https://raw.githubusercontent.com/freak2geek/environment-helpers/master/helpers/envrc-dynamic-loader.sh)"


BREW_PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
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

function hasBrew() {
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
    (isLinux && hasBrew && hasBrewConfig) || (isOSX && hasBrew)
}

function installBrew() {
    printf "${BLUE}[-] Installing brew...${NC}\n"
    setupBrewOS
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    export PATH="${BREW_PATH}:$PATH"
    eval "${BREW_UMASK}"
    brew install gcc
}

function configBrew() {
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

function uninstallBrew() {
    if hasBrew; then
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

    if ! hasBrew; then
        installBrew
    fi

    if ! hasBrewConfig; then
        configBrew
    fi
}

function purgeBrew() {
    if ! hasBrew; then
        return
    fi

    uninstallBrew
    purgeBrewOS
}

# Terminal colors
# Check: https://gist.github.com/vratiu/9780109
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BBLUE='\033[1;34m'

# Dirs
METEOR_TOOL_DIR=~/.meteor/packages/meteor-tool


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
    [[ "$(brew list | grep -ic "dnsmasq")" -eq "1" ]]
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
    [[ -f ./.git/config ]]
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
    if ! isOSX; then
        printf "${PURPLE}[-] OS not supported yet. Please install dnsmasq manually.${NC}\n"
        return
    fi

    if hasDnsmasq && hasDnsmasqConfig; then
        printf "${GREEN}[✔] dnsmasq${NC}\n"
    else
        printf "${RED}[x] dnsmasq${NC}\n"
    fi
}

function setupDnsmasq() {
    if ! isOSX; then
        printf "${PURPLE}[-] OS not supported yet. Please install dnsmasq manually.${NC}\n"
        return
    fi

    if hasDnsmasq && hasDnsmasqConfig; then
        printf "${GREEN}[✔] Already dnsmasq${NC}\n"
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
    which git-flow >/dev/null && [[ "$(which git-flow | grep -ic "not found")" -eq "0" ]]
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
    [[ -f ./.git/config ]]
}

function hasGitFlowConfig() {
    hasGitConfig && cat ./.git/config | grep -icq "\[gitflow \"prefix\"\]" && cat ./.git/config | grep -icq "\[gitflow \"branch\"\]"
}

function purgeGitFlowConfig() {
    sedi '/\[gitflow \"prefix\"\]/d' ./.git/config
    sedi '/bugfix =/d' ./.git/config
    sedi '/feature =/d' ./.git/config
    sedi '/release =/d' ./.git/config
    sedi '/hotfix =/d' ./.git/config
    sedi '/support =/d' ./.git/config
    sedi '/versiontag =/d' ./.git/config
    sedi '/\[gitflow \"branch\"\]/d' ./.git/config
    sedi '/master =/d' ./.git/config
    sedi '/develop =/d' ./.git/config
}

function configGitFlow() {
    printf "${BLUE}[-] Configuring git-flow...${NC}\n"

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi

    tryPrintNewLine ./.git/config

    printf "[gitflow \"prefix\"]" >>./.git/config
    printf "\n\tbugfix = ${GITFLOW_BUGFIX}" >>./.git/config
    printf "\n\tfeature = ${GITFLOW_FEATURE}" >>./.git/config
    printf "\n\trelease = ${GITFLOW_RELEASE}" >>./.git/config
    printf "\n\thotfix = ${GITFLOW_HOTFIX}" >>./.git/config
    printf "\n\tsupport = ${GITFLOW_SUPPORT}" >>./.git/config
    printf "\n\tversiontag = ${GITFLOW_VERSIONTAG}" >>./.git/config
    printf "\n[gitflow \"branch\"]" >>./.git/config
    printf "\n\tmaster = ${GITFLOW_MASTER}" >>./.git/config
    printf "\n\tdevelop = ${GITFLOW_DEVELOP}" >>./.git/config
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

function hasGlobalEnvrcInBash() {
    [[ -f ~/.bashrc ]] && [[ "$(cat ~/.bashrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalEnvrcInBash() {
    [[ -f ~/.bashrc ]] && [[ "$(cat ~/.bashrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function hasGlobalEnvrcInZsh() {
    [[ -f ~/.zshrc ]] && [[ "$(cat ~/.zshrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalEnvrcInZsh() {
    [[ -f ~/.zshrc ]] && [[ "$(cat ~/.zshrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function getLocalHomeVarName() {
    localDirName=${PWD##*/}
    localDirName=$(echo ${localDirName} | sedr 's/\-/_/g')
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
    hasBashrc && hasLocalHome && hasGlobalEnvrcInBash && hasGlobalEnvrcInZsh && hasLocalEnvrcInBash &&
        hasLocalEnvrcInZsh && hasDynamicEnvrcLoader
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
        printf "${GREEN}[✔] local home${NC}\n"
    fi

    if ! hasGlobalEnvrcInBash || ! hasGlobalEnvrcInZsh; then
        tryPrintNewLine ~/.envrc
        [[ -s ~/.envrc ]] && source ~/.envrc
    fi

    if ! hasLocalEnvrcInBash || ! hasLocalEnvrcInZsh; then
        tryPrintNewLine ~/.envrc
        [[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc
    fi

    if ! hasGlobalEnvrcInBash; then
        tryPrintNewLine ~/.bashrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.bashrc
        printf "${GREEN}[✔] global .envrc in bash${NC}\n"
    fi

    if ! hasLocalEnvrcInBash; then
        tryPrintNewLine ~/.bashrc
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.bashrc
        printf "${GREEN}[✔] local .envrc in bash${NC}\n"
    fi

    if ! hasGlobalEnvrcInZsh; then
        tryPrintNewLine ~/.zshrc
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.zshrc
        printf "${GREEN}[✔] global .envrc in zsh${NC}\n"
    fi

    if ! hasLocalEnvrcInZsh; then
        tryPrintNewLine ~/.zshrc
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.zshrc
        printf "${GREEN}[✔] local .envrc in zsh${NC}\n"
    fi

    if ! hasDynamicEnvrcLoader; then
        tryPrintNewLine ~/.envrc
        echo "[[ -s ~/.envrc-dl ]] && source ~/.envrc-dl" >>~/.envrc
        printf "${GREEN}[✔] dynamic .envrc loader${NC}\n"
    fi
}

function setupEnvrc() {
    # ensure the dynamic loader is always updated to latest
    rm ~/.envrc-dl
    echo "${ENVRC_DYNAMIC_LOADER}" >>~/.envrc-dl

    if hasEnvrc; then
        printf "${GREEN}[✔] Already .envrc${NC}\n"
        return
    fi

    configEnvrc
}

function checkEnvrc() {
    if hasEnvrc; then
        printf "${GREEN}[✔] .envrc${NC}\n"
    else
        printf "${RED}[x] .envrc${NC}\n"
    fi
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
      export ${line}
    done < "$1"
  fi
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



function hasMeteorLerna() {
    hasMeteor && find ${METEOR_TOOL_DIR} -type d -name "lerna" | grep -icq "lerna"
}

function installMeteorLerna() {
    printf "${BLUE}[-] Installing meteor lerna...${NC}\n"
    meteor npm install lerna -g
}

function uninstallMeteorLerna() {
    printf "${BLUE}[-] Uninstalling meteor lerna...${NC}\n"
    meteor npm uninstall lerna -g
}

function checkMeteorLerna() {
    if hasMeteorLerna; then
        printf "${GREEN}[✔] meteor lerna${NC}\n"
    else
        printf "${RED}[x] meteor lerna${NC}\n"
    fi
}

function setupMeteorLerna() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorLerna; then
        printf "${GREEN}[✔] Already meteor lerna${NC}\n"
        return
    fi

    if ! hasMeteorLerna; then
        installMeteorLerna
    fi
}

function purgeMeteorLerna() {
    if ! hasMeteorLerna; then
        return
    fi

    uninstallMeteorLerna
}

function setupProject() {
    printf "${BLUE}[-] Installing \"${PROJECT_NAME}\" project...${NC}\n"
    meteor lerna bootstrap $@
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
   hasMeteor && find ${METEOR_TOOL_DIR} -type d -name "m" | grep -icq "m"
}

function installMeteorM() {
    printf "${BLUE}[-] Installing meteor m...${NC}\n"
    meteor npm install m -g
}

function uninstallMeteorM() {
    printf "${BLUE}[-] Uninstalling meteor m...${NC}\n"
    meteor npm uninstall m -g
}

function configMeteorM() {
    printf "${BLUE}[-] Configuring meteor m...${NC}\n"
    sudo chmod -R 777 /usr/local
}

function checkMeteorM() {
    if hasMeteorM; then
        printf "${GREEN}[✔] meteor m${NC}\n"
    else
        printf "${RED}[x] meteor m${NC}\n"
    fi
}

function setupMeteorM() {
    if ! hasMeteor; then
        setupMeteor
    fi

    if hasMeteorM; then
        printf "${GREEN}[✔] Already meteor m${NC}\n"
        return
    fi

    installMeteorM
}

function purgeMeteorM() {
    if ! hasMeteorM; then
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
    setupMeteorM
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

function connectMongo() {
    if ! hasMongo; then
        return
    fi

    if isRunningMongo; then
        printf "${GREEN}[✔] Already running mongo \"${MONGO_VERSION}\"${NC}\n"
        return
    fi

    printf "${BLUE}[-] Connecting to mongo \"${MONGO_VERSION}\"...${NC}\n"
    sudo meteor m use ${MONGO_VERSION} --port ${MONGO_PORT} --dbpath ${MONGO_DBPATH} --fork --logpath ${MONGO_LOGPATH} --journal

    while ! nc -z localhost ${MONGO_PORT} </dev/null; do sleep 1; done

    if isRunningMongo; then
        printf "${GREEN}[✔] Already running mongo \"${MONGO_VERSION}\"${NC}\n"
    else
        printf "${RED}[x] An error running mongo \"${MONGO_VERSION}\"${NC}\n"
    fi
}

function shutdownMongo() {
    printf "${BLUE}[-] Disconnecting to mongo \"${MONGO_VERSION}\"...${NC}\n"

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
    meteor m shell ${MONGO_VERSION} --eval "rs.conf()" | grep -icq "\"_id\" : \"rs0\""
}

function hasOplogInitialized() {
    meteor m shell ${MONGO_VERSION} --eval "db.getSiblingDB('local').getCollection('system.replset').findOne({\"_id\":\"${MONGO_REPLICA}\"})" | grep -icq "\"_id\" : \"rs0\""
}

function hasOplogUser() {
    meteor m shell ${MONGO_VERSION} --eval "db.getSiblingDB('admin').getCollection('system.users').findOne({\"user\":\"oplogger\"})" | grep -icq "\"user\" : \"oplogger\""
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

function connectMongoAndReplicas() {
    if isRunningMongoAndReplicas; then
        printf "${GREEN}[✔] Already running mongo \"${MONGO_VERSION}\" and replicas${NC}\n"
        return
    fi

    printf "${BLUE}[-] Connecting to mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

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
    printf "${BLUE}[-] Disconnecting to mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

    meteor m mongo ${MONGO_VERSION} --port ${MONGO_PORT} --eval "db.getSiblingDB('admin').shutdownServer()" 1> /dev/null
    meteor m mongo ${MONGO_VERSION} --port ${MONGO_R1_PORT} --eval "db.getSiblingDB('admin').shutdownServer()" 1> /dev/null
    meteor m mongo ${MONGO_VERSION} --port ${MONGO_R2_PORT} --eval "db.getSiblingDB('admin').shutdownServer()" 1> /dev/null

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
        connectMongo 1>/dev/null
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
        connectMongoAndReplicas
    fi
    if hasOplogInitialized; then
        printf "${GREEN}[✔] Already oplog initialized${NC}\n"
    else
        OPLOG_CONFIG="{\"_id\":\"${MONGO_REPLICA}\",\"members\":[{\"_id\":0,\"host\":\"127.0.0.1:${MONGO_PORT}\"},{\"_id\":1,\"host\":\"127.0.0.1:${MONGO_R1_PORT}\"},{\"_id\":2,\"host\":\"127.0.0.1:${MONGO_R2_PORT}\"}]}"
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
        connectMongo
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
        connectMongo
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
    APP_TO=${1}
    printf "${BLUE}[-] Checking \"${APP_TO}\" app...${NC}\n"

    checkYarnDeps ./${APPS_PATH}/${APP_TO}
}

function setupApp() {
    APP_TO=${1}
    printf "${BLUE}[-] Installing \"${APP_TO}\" app...${NC}\n"

    meteor yarn --cwd ./${APPS_PATH}/${APP_TO} install ${@:2}
}


function hasMeteor() {
    which meteor >/dev/null && [[ "$(which meteor | grep -ic "not found")" -eq "0" ]]
}

function installMeteor() {
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

APPS_PATH='.'
APP_CONFIG_PATH='private/config'

PORT=3000
APP_TO=''
ENV_TO=''
ENV_OVERRIDE=''

function loadMeteorEnv() {
    meteorEnvPath=./${APPS_PATH}/${APP_TO}/${APP_CONFIG_PATH}/${ENV_TO}/.env
    printf "${PURPLE} - Env Path: ${meteorEnvPath}${NC}\n"
    loadEnv ${meteorEnvPath}
}

function startMeteorApp() {
    printf "${BLUE}[-] Starting \"${APP_TO}\" app...${NC}\n"
    printf "${PURPLE} - Env: ${ENV_TO}${NC}\n"

    loadMeteorEnv

    printf "${PURPLE} - Env Override: ${ENV_OVERRIDE}${NC}\n"
    eval ${ENV_OVERRIDE}

    cd ./${APPS_PATH}/${APP_TO}
    meteorSettingsPath=./${APP_CONFIG_PATH}/${ENV_TO}/settings.json
    printf "${PURPLE} - Settings Path: ${meteorSettingsPath}${NC}\n"
    printf "${PURPLE} - Port: ${PORT}${NC}\n"
    meteor run --settings ${meteorSettingsPath} --port ${PORT} $@
}

function killMeteorApp() {
    printf "${BLUE}[-] Killing \"${APP_TO}\" app...${NC}\n"
    printf "${PURPLE} - Port: ${PORT}${NC}\n"

    loadMeteorEnv

    killProcessByPort ${PORT}
}


function hasRvm() {
    which rvm >/dev/null && [[ "$(which rvm | grep -ic "not found")" -eq "0" ]]
}

function hasRuby() {
    which ruby >/dev/null && [[ "$(which ruby | grep -ic "not found")" -eq "0" ]]
}

function installRvm() {
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


function hasZsh() {
    which zsh >/dev/null && [[ "$(which zsh | grep -ic "not found")" -eq "0" ]]
}

function hasOhMyZsh() {
    [[ -d "${HOME}/.oh-my-zsh" ]]
}

function hasZshrc() {
    [[ -f "${HOME}/.oh-my-zsh/custom/plugins/zshrc/zshrc.plugin.zsh" ]]
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
    printf "${BLUE}[-] Installing zsh...${NC}\n"
    yes | curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
}

function uninstallOhMyZsh() {
    printf "${BLUE}[-] Uninstalling OhMyZsh...${NC}\n"
    rm -rf "${HOME}/.oh-my-zsh"
}

function installZshrc() {
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
