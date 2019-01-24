#!/usr/bin/env bash


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
        echo "export PATH='${BREW_PATH}'":'"$PATH"' >>~/.envrc
    fi

    if ! hasBrewUmaskConfig; then
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
NC='\033[0m'

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BBLUE='\033[1;34m'

# Dirs
METEOR_TOOL_DIR=~/.meteor/packages/meteor-tool


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

    if ! endsWithNewLine "./.git/config"; then
        printf "\n" >>./.git/config
    fi

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
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >>~/.bash_profile
}

function setupBashrc() {
    if hasBashrc; then
        return
    fi

    configBashrc
}

function hasGlobalEnvrcInBash() {
    [[ "$(cat ~/.bashrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalEnvrcInBash() {
    [[ "$(cat ~/.bashrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function hasGlobalEnvrcInZsh() {
    [[ "$(cat ~/.zshrc | grep -ic "source ~/.envrc")" -ne "0" ]]
}

function hasLocalEnvrcInZsh() {
    [[ "$(cat ~/.zshrc | grep -ic "source ${PWD}/.envrc")" -ne "0" ]]
}

function getLocalHomeVarName() {
    localDirName=${PWD##*/}
    localDirName=$(echo ${localDirName} | sed -r 's/\-/_/g')
    localHomeName=${localDirName^^}
    echo "${localHomeName}_HOME"
}

function hasLocalHome() {
    localHomeName="$(getLocalHomeVarName)"
    [[ "$(cat ~/.envrc | grep -ic "export ${localHomeName}=${PWD}")" -ne "0" ]]
}

function hasEnvrc() {
    (! hasZshrc && hasGlobalEnvrcInBash && hasLocalEnvrcInBash && hasLocalHome) || (hasZshrc && hasGlobalEnvrcInZsh && hasLocalEnvrcInZsh && hasLocalHome)
}

function configEnvrc() {
    printf "${BLUE}[-] Configuring .envrc...${NC}\n"

    if ! hasBashrc; then
        setupBashrc
    fi

    if ! hasGlobalEnvrcInBash; then
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.bashrc
        printf "${GREEN}[✔] global .envrc in bash${NC}\n"
    fi

    if ! hasLocalEnvrcInBash; then
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.bashrc
        printf "${GREEN}[✔] local .envrc in bash${NC}\n"
    fi

    if ! hasGlobalEnvrcInZsh; then
        echo "[[ -s ~/.envrc ]] && source ~/.envrc" >>~/.zshrc
        printf "${GREEN}[✔] global .envrc in zsh${NC}\n"
    fi

    if ! hasLocalEnvrcInZsh; then
        echo "[[ -s ${PWD}/.envrc ]] && source ${PWD}/.envrc" >>~/.zshrc
        printf "${GREEN}[✔] local .envrc in zsh${NC}\n"
    fi

    if ! hasLocalHome; then
        localHomeName="$(getLocalHomeVarName)"
        echo "export ${localHomeName}=${PWD}" >>~/.envrc
        printf "${GREEN}[✔] local home${NC}\n"
    fi
}

function setupEnvrc() {
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
    test "$(tail -c 1 "$1" | wc -l)" -ne 0
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

function sudoSedi() {
  sed --version >/dev/null 2>&1 && sudo sed -i -- "$@" || sudo sed -i "" "$@"
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


# MONGO default config
MONGO_VERSION="stable"
MONGO_CONF="/etc/mongodb.conf"
MONGO_DBPATH="/data/db"
MONGO_LOGPATH="/var/log/mongod.log"
MONGO_REPLICA="rs0"
MONGO_R1_DBPATH="/data/db-rs0-0"
MONGO_R2_DBPATH="/data/db-rs0-1"
MONGO_R1_LOGPATH="/var/log/mongod-rs0-0.log"
MONGO_R2_LOGPATH="/var/log/mongod-rs0-1.log"

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

function connectMongo() {
    if ! hasMongo; then
        return
    fi

    printf "${BLUE}[-] Connecting to mongo \"${MONGO_VERSION}\"...${NC}\n"
    sudo meteor m use ${MONGO_VERSION} --port 27017 --dbpath ${MONGO_DBPATH} --fork --logpath ${MONGO_LOGPATH} --journal

    while ! nc -z localhost 27017 </dev/null; do sleep 1; done
}

function shutdownMongo() {
    printf "${BLUE}[-] Disconnecting to mongo \"${MONGO_VERSION}\"...${NC}\n"

    if ! hasMongo; then
        return
    fi

    meteor m mongo ${MONGO_VERSION} --port 27017 --eval "db.getSiblingDB('admin').shutdownServer()"
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

function connectMongoAndReplicas() {
    printf "${BLUE}[-] Connecting to mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port 27017 --dbpath ${MONGO_DBPATH} --fork --logpath ${MONGO_LOGPATH} --replSet ${MONGO_REPLICA} --journal
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port 27018 --dbpath ${MONGO_R1_DBPATH} --fork --logpath ${MONGO_R1_LOGPATH} --replSet ${MONGO_REPLICA} --journal
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port 27019 --dbpath ${MONGO_R2_DBPATH} --fork --logpath ${MONGO_R2_LOGPATH} --replSet ${MONGO_REPLICA} --journal

    while ! nc -z localhost 27017 </dev/null; do sleep 1; done
    while ! nc -z localhost 27018 </dev/null; do sleep 1; done
    while ! nc -z localhost 27019 </dev/null; do sleep 1; done
}

function shutdownMongoAndReplicas() {
    printf "${BLUE}[-] Disconnecting to mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

    meteor m mongo ${MONGO_VERSION} --port 27017 --eval "db.getSiblingDB('admin').shutdownServer()"
    meteor m mongo ${MONGO_VERSION} --port 27018 --eval "db.getSiblingDB('admin').shutdownServer()"
    meteor m mongo ${MONGO_VERSION} --port 27019 --eval "db.getSiblingDB('admin').shutdownServer()"
}

function repairMongoAndReplicas() {
    printf "${BLUE}[-] Repairing mongo \"${MONGO_VERSION}\" and replicas...${NC}\n"

    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port 27017 --dbpath ${MONGO_DBPATH} --repair
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port 27018 --dbpath ${MONGO_R1_DBPATH} --repair
    sudo meteor m use ${MONGO_VERSION} --config ${MONGO_CONF} --port 27019 --dbpath ${MONGO_R2_DBPATH} --repair
}

function checkMongoOplog() {
    if ! hasMongo || ! hasMongoConfig; then
        printf "${RED}[x] meteor mongo oplog${NC}\n"
        return
    fi

    connectMongo 1>/dev/null
    if hasOlogConfig; then
        printf "${GREEN}[✔] meteor mongo oplog${NC}\n"
    else
        printf "${RED}[x] meteor mongo oplog${NC}\n"
    fi
    shutdownMongo 1>/dev/null
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

    connectMongoAndReplicas
    if hasOplogInitialized; then
        printf "${GREEN}[✔] Already oplog initialized${NC}\n"
    else
        OPLOG_CONFIG="{\"_id\":\"${MONGO_REPLICA}\",\"members\":[{\"_id\":0,\"host\":\"127.0.0.1:27017\"},{\"_id\":1,\"host\":\"127.0.0.1:27018\"},{\"_id\":2,\"host\":\"127.0.0.1:27019\"}]}"
        if hasOplogConf; then
            meteor m shell ${MONGO_VERSION} --port 27017 --eval "rs.reconfig(${OPLOG_CONFIG})"
        else
            meteor m shell ${MONGO_VERSION} --port 27017 --eval "rs.initiate(${OPLOG_CONFIG})"
        fi
    fi
    shutdownMongoAndReplicas 1>/dev/null

    connectMongo
    if hasOplogUser; then
        printf "${GREEN}[✔] Already oplog user${NC}\n"
    else

        meteor m shell ${MONGO_VERSION} --port 27017 --eval "db.getSiblingDB('admin').createUser({\"user\":\"oplogger\",\"pwd\":\"PASSWORD\",\"roles\":[{\"role\":\"read\",\"db\":\"local\"}],\"passwordDigestor\":\"server\"})"
    fi
    shutdownMongo 1>/dev/null
}

function purgeMongoOplog() {
    printf "${BLUE}[-] Purging oplog...${NC}\n"

    wasConnected=$(hasMongoConnected)
    if [[ ${wasConnected} -eq 0 ]]; then
        connectMongo
    fi

    if hasOplogUser; then
        meteor m shell ${MONGO_VERSION} --port 27017 --eval "db.getSiblingDB('admin').getCollection('system.users').deleteOne({\"user\":\"oplogger\"})"
    fi

    if hasOplogInitialized; then
        meteor m shell ${MONGO_VERSION} --port 27017 --eval "db.getSiblingDB('local').getCollection('system.replset').deleteOne({\"_id\":\"rs0\"})"
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
  [[ $(cat ~/.envrc | grep -ic 'export SHELL=$(which zsh)') -ne "0" ]]
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
    sedi '/which zsh/d' ~/.envrc
    sedi '/$ZSH_VERSION/d' ~/.envrc
    printf "${PURPLE}Please, restart your shell to use back your bash.${NC}\n"
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
    printf '\n export SHELL=$(which zsh)' >>~/.envrc
    printf '\n [[ -z "$ZSH_VERSION" ]] && exec "$SHELL" -l' >>~/.envrc
    printf "${PURPLE}Please, restart your shell to use zsh.${NC}\n"
    # Alternative method
    # if [[ $(cat /etc/shells | grep -ic "$(which zsh)") -eq "0" ]]; then
    #    which zsh | sudo tee -a /etc/shells
    # fi
    # chsh -s $(which zsh)
}
