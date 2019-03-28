#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"
source "./src/meteor.sh"

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
    installMeteorLib m
}

function uninstallMeteorM() {
    uninstallMeteorLib m
}

function configMeteorM() {
    printf "${BLUE}[-] Configuring meteor m...${NC}\n"
    sudo chmod -R 777 /usr/local
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
