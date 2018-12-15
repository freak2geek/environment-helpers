#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/meteor.sh"

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

function configureMeteorM() {
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
    configureMeteorM
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
    yes | meteor m ${version}
}

function uninstallMongo() {
    version=${1-'stable'}
    printf "${BLUE}[-] Uninstalling mongo@${version}...${NC}\n"
    yes | meteor m rm ${version}
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
    dbReplicaOne=$(getReplicaFile ${dbpath} '1')
    dbReplicaTwo=$(getReplicaFile ${dbpath} '2')
    logReplicaOne=$(getReplicaFile ${logpath} '1')
    logReplicaTwo=$(getReplicaFile ${logpath} '2')

    [[ -f ${mongoConf} ]] && ls -la ${mongoConf} | grep -icq "\-rwxrwxrwx .* ${mongoConf}" &&
    [[ -d  ${dbpath} ]] && ls -la ${dbpath} | grep -icq "drwxrwxrwx .* \." &&
    [[ -d  ${dbReplicaOne} ]] && ls -la ${dbReplicaOne} | grep -icq "drwxrwxrwx .* \." &&
    [[ -d  ${dbReplicaTwo} ]] && ls -la ${dbReplicaTwo} | grep -icq "drwxrwxrwx .* \." &&
    [[ -f ${logpath} ]] && ls -la ${logpath} | grep -icq "\-rw\-r\-\-r\-\- .* ${logpath}" &&
    [[ -f ${logReplicaOne} ]] && ls -la ${logReplicaOne} | grep -icq "\-rw\-r\-\-r\-\- .* ${logReplicaOne}" &&
    [[ -f ${logReplicaTwo} ]] && ls -la ${logReplicaTwo} | grep -icq "\-rw\-r\-\-r\-\- .* ${logReplicaTwo}"
}

function configMongo() {
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}
    dbReplicaOne=$(getReplicaFile ${dbpath} '1')
    dbReplicaTwo=$(getReplicaFile ${dbpath} '2')
    logReplicaOne=$(getReplicaFile ${logpath} '1')
    logReplicaTwo=$(getReplicaFile ${logpath} '2')

    if hasMongoConfig $@; then
        printf "${GREEN}[✔] Already mongo.conf \"${mongoConf}\"${NC}\n"
        printf "${GREEN}[✔] Already dbpath \"${dbpath}\"${NC}\n"
        printf "${GREEN}[✔] Already logpath \"${logpath}\"${NC}\n"
        printf "${GREEN}[✔] Already dbReplicaOne \"${dbReplicaOne}\"${NC}\n"
        printf "${GREEN}[✔] Already dbReplicaTwo \"${dbReplicaTwo}\"${NC}\n"
        printf "${GREEN}[✔] Already logReplicaOne \"${logReplicaOne}\"${NC}\n"
        printf "${GREEN}[✔] Already logReplicaTwo \"${logReplicaTwo}\"${NC}\n"
        return
    fi

    printf "${BLUE}[-] Configuring mongoConf \"${mongoConf}\"...${NC}\n"
    sudo touch ${mongoConf}
    sudo chmod -R 777 ${mongoConf}
    printf "${BLUE}[-] Configuring dbpath \"${dbpath}\"...${NC}\n"
    sudo mkdir -p ${dbpath}
    sudo chmod -R 777 ${dbpath}
    printf "${BLUE}[-] Configuring dbReplicaOne \"${dbReplicaOne}\"...${NC}\n"
    sudo mkdir -p ${dbReplicaOne}
    sudo chmod -R 777 ${dbReplicaOne}
    printf "${BLUE}[-] Configuring dbReplicaOne \"${dbReplicaTwo}\"...${NC}\n"
    sudo mkdir -p ${dbReplicaTwo}
    sudo chmod -R 777 ${dbReplicaTwo}
    printf "${BLUE}[-] Configuring logpath \"${logpath}\"...${NC}\n"
    sudo touch ${logpath}
    printf "${BLUE}[-] Configuring logReplicaOne \"${logReplicaOne}\"...${NC}\n"
    sudo touch ${logReplicaOne}
    printf "${BLUE}[-] Configuring logReplicaTwo \"${logReplicaTwo}\"...${NC}\n"
    sudo touch ${logReplicaTwo}
}

function setupMongo() {
    setupMeteorM
    configMongo $@
    installMongo $@
}

function purgeMongo() {
    uninstallMongo $@
}

function hasOplog() {
    # TODO
}

function checkOplog() {
    # TODO
}

function configOplog() {
    version=${1-'stable'}
    mongoConf=${2-'/etc/mongodb.conf'}
    dbpath=${3-'/data/db'}
    logpath=${4-'/var/log/mongod.log'}
    dbReplicaOne=$(getReplicaFile ${dbpath} '1')
    dbReplicaTwo=$(getReplicaFile ${dbpath} '2')
    logReplicaOne=$(getReplicaFile ${logpath} '1')
    logReplicaTwo=$(getReplicaFile ${logpath} '2')

    sudo echo "replSet = rs0" >> ${mongoConf}
    sudo meteor m use ${version} --port 27017 --dbpath ${dbpath} --fork --logpath ${logpath} --replSet rs0 --smallfiles --oplogSize 128
    sudo meteor m use ${version} --port 27018 --dbpath ${dbReplicaOne} --fork --logpath ${logReplicaOne} --replSet rs0 --smallfiles --oplogSize 128
    sudo meteor m use ${version} --port 27019 --dbpath ${dbReplicaTwo} --fork --logpath ${logReplicaTwo} --replSet rs0 --smallfiles --oplogSize 128
    sudo meteor m shell ${version} --port 27017 --eval "rs.initiate({\"_id\":\"rs0\",\"members\":[{\"_id\":0,\"host\":\"127.0.0.1:27017\"},{\"_id\":1,\"host\":\"127.0.0.1:27018\"},{\"_id\":2,\"host\":\"127.0.0.1:27019\"}]})"
    sudo meteor m shell ${version} --port 27017 --eval "db.getSiblingDB('admin').createUser({\"user\":\"oplogger\",\"pwd\":\"PASSWORD\",\"roles\":[{\"role\":\"read\",\"db\":\"local\"}],\"passwordDigestor\":\"server\"})"
    sudo meteor m mongo ${version} --port 27017 --eval "db.getSiblingDB('admin').shutdownServer()"
    sudo meteor m mongo ${version} --port 27018 --eval "db.getSiblingDB('admin').shutdownServer()"
    sudo meteor m mongo ${version} --port 27019 --eval "db.getSiblingDB('admin').shutdownServer()"
}
