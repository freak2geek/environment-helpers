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
    sudo meteor m use ${version} --port 27017 --dbpath ${dbpath} --fork --logpath ${logpath} >/dev/null

    while ! nc -z localhost 27017 </dev/null; do sleep 1; done
}

function shutdownMongo() {
    version=${1-'stable'}
    printf "${BLUE}[-] Disconnecting to mongo \"${version}\"...${NC}\n"

    meteor m mongo ${version} --port 27017 --eval "db.getSiblingDB('admin').shutdownServer()" >/dev/null
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

    sudo meteor m use ${version} --port 27017 --dbpath ${dbpath} --fork --logpath ${logpath} --replSet rs0 --smallfiles --oplogSize 128 >/dev/null
    sudo meteor m use ${version} --port 27018 --dbpath ${dbReplicaOne} --fork --logpath ${logReplicaOne} --replSet rs0 --smallfiles --oplogSize 128 >/dev/null
    sudo meteor m use ${version} --port 27019 --dbpath ${dbReplicaTwo} --fork --logpath ${logReplicaTwo} --replSet rs0 --smallfiles --oplogSize 128 >/dev/null

    # Add a delay to wait the replicas to be loaded
    # https://stackoverflow.com/a/50397775
    while ! nc -z localhost 27017 </dev/null; do sleep 1; done
    while ! nc -z localhost 27018 </dev/null; do sleep 1; done
    while ! nc -z localhost 27019 </dev/null; do sleep 1; done
}

function shutdownMongoAndReplicas() {
    version=${1-'stable'}
    printf "${BLUE}[-] Disconnecting to mongo \"${version}\" and replicas \"${version}\"...${NC}\n"

    meteor m mongo ${version} --port 27017 --eval "db.getSiblingDB('admin').shutdownServer()" >/dev/null
    meteor m mongo ${version} --port 27018 --eval "db.getSiblingDB('admin').shutdownServer()" >/dev/null
    meteor m mongo ${version} --port 27019 --eval "db.getSiblingDB('admin').shutdownServer()" >/dev/null
}

function checkOplog() {
    connectMongo $@
    if hasOlogConfig $@; then
        printf "${GREEN}[✔] meteor m oplog${NC}\n"
    else
        printf "${RED}[x] meteor m oplog${NC}\n"
    fi
    shutdownMongo $@
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

    configMongo

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
