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
    which brew >/dev/null && [[ $(which brew | grep -ic "not found") -eq "0" ]]
}

function hasBrewPathConfig() {
    cat ~/.bashrc | grep -icq "${BREW_PATH}"
}

function hasBrewUmaskConfig() {
    cat ~/.bashrc | grep -icq "${BREW_UMASK}"
}

function hasBrewConfig() {
   hasBrewPathConfig && hasBrewUmaskConfig
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
    setupBashrc

    printf "${BLUE}[-] Configuring brew...${NC}\n"

    if ! hasBrewPathConfig; then
        echo "export PATH='${BREW_PATH}'":'"$PATH"' >>~/.bashrc
    fi

    if ! hasBrewUmaskConfig; then
        echo "${BREW_UMASK}" >>~/.bashrc
    fi
}

function uninstallBrew() {
    if hasBrew; then
        printf "${BLUE}[-] Uninstall brew...${NC}\n"
        yes | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/uninstall)"
    fi
    test -e /home/linuxbrew/.linuxbrew/bin/brew && brew purge
    sed -i '/linuxbrew/d' ~/.bashrc
    sed -i "/${BREW_UMASK}/d" ~/.bashrc
    test -d /home/linuxbrew/.linuxbrew/bin && rm -R /home/linuxbrew/.linuxbrew/bin
    test -d /home/linuxbrew/.linuxbrew/lib && rm -R /home/linuxbrew/.linuxbrew/lib
    test -d /home/linuxbrew/.linuxbrew/share && rm -R /home/linuxbrew/.linuxbrew/share
}

function checkBrew() {
    if hasBrew && hasBrewConfig; then
        printf "${GREEN}[✔] brew${NC}\n"
    else
        printf "${RED}[x] brew${NC}\n"
    fi
}

function setupBrew() {
    if hasBrew && hasBrewConfig; then
        printf "${GREEN}[✔] Already brew${NC}\n"
        return
    fi

    if ! hasBrew && [[ "$OSTYPE" == "linux-gnu" ]]; then
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


function hasDocker() {
    which docker >/dev/null && [[ $(which docker | grep -ic "not found") -eq "0" ]]
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


function hasGitFlow() {
    which git-flow >/dev/null && [[ $(which git-flow | grep -ic "not found") -eq "0" ]]
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
    sed -i '/\[gitflow \"prefix\"\]/d' ./.git/config
    sed -i '/bugfix =/d' ./.git/config
    sed -i '/feature =/d' ./.git/config
    sed -i '/release =/d' ./.git/config
    sed -i '/hotfix =/d' ./.git/config
    sed -i '/support =/d' ./.git/config
    sed -i '/versiontag =/d' ./.git/config
    sed -i '/\[gitflow \"branch\"\]/d' ./.git/config
    sed -i '/master =/d' ./.git/config
    sed -i '/develop =/d' ./.git/config
}

function configGitFlow() {
    printf "${BLUE}[-] Configuring git-flow...${NC}\n"

    bugfix=${1-'bugfix/'}
    feature=${2-'feature/'}
    release=${3-'release/'}
    hotfix=${4-'hotfix/'}
    support=${5-'support/'}
    versiontag=${6-''}
    master=${7-'master'}
    develop=${8-'development'}

    if hasGitFlowConfig; then
        purgeGitFlowConfig
    fi

    if ! endsWithNewLine "./.git/config"; then
        printf "\n" >>./.git/config
    fi

    printf "[gitflow \"prefix\"]" >>./.git/config
    printf "\n\tbugfix = ${bugfix}" >>./.git/config
    printf "\n\tfeature = ${feature}" >>./.git/config
    printf "\n\trelease = ${release}" >>./.git/config
    printf "\n\tsupport = ${support}" >>./.git/config
    printf "\n\tversiontag = ${versiontag}" >>./.git/config
    printf "\n[gitflow \"branch\"]" >>./.git/config
    printf "\n\tmaster = ${master}" >>./.git/config
    printf "\n\tdevelop = ${develop}" >>./.git/config
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
        configGitFlow $@
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
    which git >/dev/null && [[ $(which git | grep -ic "not found") -eq "0" ]]
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
    [[ -f ~/.bash_profile ]] && [[ $(cat ~/.bash_profile | grep -ic "${BASHRC_IMPORT}") -ne "0" ]]
}

function configBashrc() {
    printf "${BLUE}[-] Configuring bashrc...${NC}\n"
    echo "[[ -s ~/.bashrc ]] && ${BASHRC_IMPORT}" >> ~/.bash_profile
}

function setupBashrc() {
    if hasBashrc; then
        printf "${GREEN}[✔] Already bashrc${NC}\n"
        return
    fi

    configBashrc
}

function endsWithNewLine() {
    test "$(tail -c 1 "$1" | wc -l)" -ne 0
}



function hasMeteorM() {
    meteor npm ls --depth 0 -g 2>/dev/null | grep -icq " m@"
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
    version=${1-'stable'}
    meteor m | grep -icq "ο.*${version}"
}

function installMongo() {
    version=${1-'stable'}
    if hasMongo $@; then
        printf "${GREEN}[✔] Already mongo@${version}${NC}\n"
        return;
    fi
    printf "${BLUE}[-] Installing mongo@${version}...${NC}\n"
    yes | sudo meteor m ${version}
}

function uninstallMongo() {
    version=${1-'stable'}
    printf "${BLUE}[-] Uninstalling mongo@${version}...${NC}\n"
    yes | sudo meteor m rm ${version}
}

function getReplicaFile() {
    file=${1-''}
    replica=${2-'0'}
    echo $file | sed -r -e "s/(^\/.*\/)(.*(\..*)|.*)/\1rs0-${replica}\3/"
}

function hasMongoConfig() {
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}

    [[ -f ${mongoConf} ]] && ls -la ${mongoConf} | grep -icq "\-rw\-r\-\-r\-\- .* ${mongoConf}" &&
    [[ -d  ${dbpath} ]] && [[ -f ${logpath} ]]
}

function configMongo() {
    version=${1-'stable'}
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}

    if hasMongoConfig $@; then
        printf "${GREEN}[✔] Already mongo.conf \"${mongoConf}\"${NC}\n"
        printf "${GREEN}[✔] Already dbpath \"${dbpath}\"${NC}\n"
        printf "${GREEN}[✔] Already logpath \"${logpath}\"${NC}\n"
        return
    fi

    printf "${BLUE}[-] Configuring mongoConf \"${mongoConf}\"...${NC}\n"
    sudo touch ${mongoConf}
    sudo chown -R ${USER}:${USER} ${mongoConf}
    printf "${BLUE}[-] Configuring dbpath \"${dbpath}\"...${NC}\n"
    sudo mkdir -p ${dbpath}
    sudo chown -R ${USER}:${USER} ${dbpath}
    printf "${BLUE}[-] Configuring logpath \"${logpath}\"...${NC}\n"
    sudo touch ${logpath}
    sudo chown -R ${USER}:${USER} ${logpath}

    sudo chown -R ${USER}:${USER} $(meteor m bin ${version})
}

function checkMongo() {
    version=${1-'stable'}
    if hasMongo $@ && hasMongoConfig $@; then
        printf "${GREEN}[✔] meteor mongo ${version}${NC}\n"
    else
        printf "${RED}[x] meteor mongo ${version}${NC}\n"
    fi
}

function setupMongo() {
    setupMeteorM $@
    installMongo $@
    configMongo $@
}

function purgeMongo() {
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}

    uninstallMongo $@

    sudo rm ${mongoConf}
    sudo rm -R ${dbpath}
    sudo rm ${logpath}
}

function connectMongo() {
    version=${1-'stable'}
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}

    printf "${BLUE}[-] Connecting to mongo \"${version}\"...${NC}\n"
    sudo meteor m use ${version} --port 27017 --dbpath ${dbpath} --fork --logpath ${logpath} 1>/dev/null

    while ! nc -z localhost 27017 </dev/null; do sleep 1; done
}

function shutdownMongo() {
    version=${1-'stable'}
    printf "${BLUE}[-] Disconnecting to mongo \"${version}\"...${NC}\n"

    meteor m mongo ${version} --port 27017 --eval "db.getSiblingDB('admin').shutdownServer()" 1>/dev/null
}

REPLICA_SET_CONFIG="replSet = rs0"
OPLOG_CONFIG="{\"_id\":\"rs0\",\"members\":[{\"_id\":0,\"host\":\"127.0.0.1:27017\"},{\"_id\":1,\"host\":\"127.0.0.1:27018\"},{\"_id\":2,\"host\":\"127.0.0.1:27019\"}]}"

function hasReplicaSetConfig() {
    mongoConf=${2-'/etc/mongodb.conf'}
    cat ${mongoConf} | grep -icq "${REPLICA_SET_CONFIG}"
}

function hasReplicaOneDBConfig() {
    dbpath=${3-'/data/db'}
    dbReplicaOne=$(getReplicaFile ${dbpath} '1')
    [[ -d  ${dbReplicaOne} ]]
}

function hasReplicaTwoDBConfig() {
    dbpath=${3-'/data/db'}
    dbReplicaTwo=$(getReplicaFile ${dbpath} '2')
    [[ -d  ${dbReplicaTwo} ]]
}

function hasReplicaOneLogsConfig() {
    logpath=${4-'/var/log/mongod.log'}
    logReplicaOne=$(getReplicaFile ${logpath} '1')
    [[ -f ${logReplicaOne} ]]
}

function hasReplicaTwoLogsConfig() {
    logpath=${4-'/var/log/mongod.log'}
    logReplicaTwo=$(getReplicaFile ${logpath} '2')
    [[ -f ${logReplicaTwo} ]]
}

function hasOplogConf() {
    version=${1-'stable'}
    meteor m shell ${version} --eval "rs.conf()" | grep -icq "\"_id\" : \"rs0\""
}

function hasOplogInitialized() {
    version=${1-'stable'}
    meteor m shell ${version} --eval "db.getSiblingDB('local').getCollection('system.replset').findOne({\"_id\":\"rs0\"})" | grep -icq "\"_id\" : \"rs0\""
}

function hasOplogUser() {
    version=${1-'stable'}
    meteor m shell ${version} --eval "db.getSiblingDB('admin').getCollection('system.users').findOne({\"user\":\"oplogger\"})" | grep -icq "\"user\" : \"oplogger\""
}

function hasOlogConfig() {
    hasMongoConfig $@ && hasReplicaSetConfig $@ && hasReplicaOneDBConfig $@ &&  hasReplicaTwoDBConfig $@ &&
    hasReplicaOneLogsConfig $@ && hasReplicaTwoLogsConfig $@ && hasOplogInitialized $@ && hasOplogUser $@
}

function hasMongoConnected() {
    version=${1-'stable'}
    ps -aux | grep -ic "$(meteor m bin ${version})"
}

function connectMongoAndReplicas() {
    version=${1-'stable'}
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}
    dbReplicaOne=$(getReplicaFile ${dbpath} '1')
    dbReplicaTwo=$(getReplicaFile ${dbpath} '2')
    logReplicaOne=$(getReplicaFile ${logpath} '1')
    logReplicaTwo=$(getReplicaFile ${logpath} '2')
    printf "${BLUE}[-] Connecting to mongo \"${version}\" and replicas...${NC}\n"

    sudo meteor m use ${version} --port 27017 --dbpath ${dbpath} --fork --logpath ${logpath} --replSet rs0 --smallfiles --oplogSize 128 1>/dev/null
    sudo meteor m use ${version} --port 27018 --dbpath ${dbReplicaOne} --fork --logpath ${logReplicaOne} --replSet rs0 --smallfiles --oplogSize 128 1>/dev/null
    sudo meteor m use ${version} --port 27019 --dbpath ${dbReplicaTwo} --fork --logpath ${logReplicaTwo} --replSet rs0 --smallfiles --oplogSize 128 1>/dev/null

    while ! nc -z localhost 27017 </dev/null; do sleep 1; done
    while ! nc -z localhost 27018 </dev/null; do sleep 1; done
    while ! nc -z localhost 27019 </dev/null; do sleep 1; done
}

function shutdownMongoAndReplicas() {
    version=${1-'stable'}
    printf "${BLUE}[-] Disconnecting to mongo \"${version}\" and replicas...${NC}\n"

    meteor m mongo ${version} --port 27017 --eval "db.getSiblingDB('admin').shutdownServer()" 1>/dev/null
    meteor m mongo ${version} --port 27018 --eval "db.getSiblingDB('admin').shutdownServer()" 1>/dev/null
    meteor m mongo ${version} --port 27019 --eval "db.getSiblingDB('admin').shutdownServer()" 1>/dev/null
}

function checkOplog() {
    connectMongo $@ 1>/dev/null
    if hasOlogConfig $@; then
        printf "${GREEN}[✔] meteor mongo oplog${NC}\n"
    else
        printf "${RED}[x] meteor mongo oplog${NC}\n"
    fi
    shutdownMongo $@ 1>/dev/null
}

function setupOplog() {
    version=${1-'stable'}
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}
    dbReplicaOne=$(getReplicaFile ${dbpath} '1')
    dbReplicaTwo=$(getReplicaFile ${dbpath} '2')
    logReplicaOne=$(getReplicaFile ${logpath} '1')
    logReplicaTwo=$(getReplicaFile ${logpath} '2')

    configMongo $@

    if hasReplicaOneDBConfig $@; then
        printf "${GREEN}[✔] Already dbReplicaOne \"${dbReplicaOne}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring dbReplicaOne \"${dbReplicaOne}\"...${NC}\n"
        sudo mkdir -p ${dbReplicaOne}
        sudo chmod -R 777 ${dbReplicaOne}
    fi

    if hasReplicaTwoDBConfig $@; then
        printf "${GREEN}[✔] Already dbReplicaOne \"${dbReplicaOne}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring dbReplicaOne \"${dbReplicaTwo}\"...${NC}\n"
        sudo mkdir -p ${dbReplicaTwo}
        sudo chmod -R 777 ${dbReplicaTwo}
    fi

    if hasReplicaOneLogsConfig $@; then
        printf "${GREEN}[✔] Already logReplicaOne \"${logReplicaOne}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring logReplicaOne \"${logReplicaOne}\"...${NC}\n"
        # [[ ! -d  "$(dirname -- ${logReplicaOne})" ]] && sudo mkdir -p -- "$(dirname -- ${logReplicaOne})"
        sudo touch ${logReplicaOne}
    fi

    if hasReplicaTwoLogsConfig $@; then
        printf "${GREEN}[✔] Already logReplicaTwo \"${logReplicaTwo}\"${NC}\n"
    else
        printf "${BLUE}[-] Configuring logReplicaTwo \"${logReplicaTwo}\"...${NC}\n"
        sudo touch ${logReplicaTwo}
    fi

    if ! hasReplicaSetConfig $@; then
        sudo echo ${REPLICA_SET_CONFIG} >> ${mongoConf}
    fi

    connectMongoAndReplicas $@
    if hasOplogInitialized $@; then
        printf "${GREEN}[✔] Already oplog initialized${NC}\n"
    else
        if hasOplogConf $@; then
            meteor m shell ${version} --port 27017 --eval "rs.reconfig(${OPLOG_CONFIG})"
        else
            meteor m shell ${version} --port 27017 --eval "rs.initiate(${OPLOG_CONFIG})"
        fi
    fi
    shutdownMongoAndReplicas $@

    connectMongo $@
    if hasOplogUser $@; then
        printf "${GREEN}[✔] Already oplog user${NC}\n"
    else

        meteor m shell ${version} --port 27017 --eval "db.getSiblingDB('admin').createUser({\"user\":\"oplogger\",\"pwd\":\"PASSWORD\",\"roles\":[{\"role\":\"read\",\"db\":\"local\"}],\"passwordDigestor\":\"server\"})"
    fi
    shutdownMongo $@
}

function purgeOplog() {
    version=${1-'stable'}
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}
    dbReplicaOne=$(getReplicaFile ${dbpath} '1')
    dbReplicaTwo=$(getReplicaFile ${dbpath} '2')
    logReplicaOne=$(getReplicaFile ${logpath} '1')
    logReplicaTwo=$(getReplicaFile ${logpath} '2')

    printf "${BLUE}[-] Purging oplog...${NC}\n"

    wasConnected=$(hasMongoConnected $@)
    if [[ ${wasConnected} -eq 0 ]]; then
        connectMongo $@
    fi

    if hasOplogUser $@; then
        meteor m shell ${version} --port 27017 --eval "db.getSiblingDB('admin').getCollection('system.users').deleteOne({\"user\":\"oplogger\"})"
    fi

    if hasOplogInitialized; then
        meteor m shell ${version} --port 27017 --eval "db.getSiblingDB('local').getCollection('system.replset').deleteOne({\"_id\":\"rs0\"})"
    fi

    if [[ ${wasConnected} -eq 0 ]]; then
        shutdownMongo $@
    fi

    if hasReplicaOneDBConfig $@; then
        sudo rm -rf ${dbReplicaOne}
    fi

    if hasReplicaTwoDBConfig $@; then
        sudo rm -rf ${dbReplicaTwo}
    fi

    if hasReplicaOneLogsConfig $@; then
        sudo rm ${logReplicaOne}
    fi

    if hasReplicaTwoLogsConfig $@; then
        sudo rm ${logReplicaTwo}
    fi

    if hasReplicaSetConfig $@; then
        sudo sed -i "/${REPLICA_SET_CONFIG}/d" ${mongoConf}
    fi
}


function hasMeteorYarn() {
    meteor npm ls --depth 0 -g 2>/dev/null | grep -icq "yarn@"
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


function hasMeteor() {
    which meteor >/dev/null && [[ $(which meteor | grep -ic "not found") -eq "0" ]]
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


function hasRvm() {
    which rvm >/dev/null && [[ $(which rvm | grep -ic "not found") -eq "0" ]]
}

function hasRuby() {
    which ruby >/dev/null && [[ $(which ruby | grep -ic "not found") -eq "0" ]]
}

function installRvm() {
    printf "${BLUE}[-] Installing rvm...${NC}\n"
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
}

function uninstallRvm() {
    printf "${BLUE}[-] Uninstalling rvm...${NC}\n"
    rm -rf ~/.rvm
    sed -i '/\.rvm\/bin/d' ~/.bashrc
    sed -i '/\.rvm\//d' ~/.bash_profile
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
    which zsh >/dev/null && [[ $(which zsh | grep -ic "not found") -eq "0" ]]
}

function hasOhMyZsh() {
    [[ -d "${HOME}/.oh-my-zsh" ]]
}

function hasZshrc() {
    [[ -f "${HOME}/.oh-my-zsh/custom/plugins/zshrc/zshrc.plugin.zsh" ]]
}

function hasZshAsDefault() {
  [[ $(cat "${HOME}/.bashrc" | grep -ic 'export SHELL=$(which zsh)') -ne "0" ]]
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
    if hasZsh && hasOhMyZsh && hasZshrc; then
        printf "${GREEN}[✔] zsh${NC}\n"
    else
        printf "${RED}[x] zsh${NC}\n"
    fi
}

function setupZsh() {
    if hasZsh && hasOhMyZsh && hasZshrc; then
        printf "${GREEN}[✔] Already zsh${NC}\n"
        return
    fi

    if ! hasZsh; then
        installZsh
    fi

    if ! hasOhMyZsh; then
        installOhMyZsh
    fi

    if ! hasZshrc; then
        installZshrc
    fi
}

function purgeZsh() {
    if hasZsh; then
        uninstallZsh
    fi

    if hasOhMyZsh; then
        uninstallOhMyZsh
    fi
}

function configZshAsDefault() {
    if hasZshAsDefault; then
        printf "${GREEN}[✔] Already zsh as default${NC}\n"
        return
    fi

    setupBashrc

    printf "${BLUE}[-] Setting zsh as default shell...${NC}\n"
    printf '\n export SHELL=$(which zsh)' >>~/.bashrc
    printf '\n [[ -z "$ZSH_VERSION" ]] && exec "$SHELL" -l' >>~/.bashrc
    # Alternative method
    # if [[ $(cat /etc/shells | grep -ic "$(which zsh)") -eq "0" ]]; then
    #    which zsh | sudo tee -a /etc/shells
    # fi
    # chsh -s $(which zsh)
}
