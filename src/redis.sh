#!/usr/bin/env bash

function hasRedis() {
    hasBrewByOS && [[ "$(brew ls redis 2>&1 | grep -ic "No such keg")" -eq "0" ]]
}

function installRedis() {
    printf "${BLUE}[-] Installing redis...${NC}\n"
    brew install redis
}

function uninstallRedis() {
    printf "${BLUE}[-] Uninstalling redis...${NC}\n"
    brew uninstall redis
}

function checkRedis() {
    if hasRedis; then
        printf "${GREEN}[✔] redis${NC}\n"
    else
        printf "${RED}[x] redis${NC}\n"
    fi
}

function setupRedis() {
    if hasRedis; then
        printf "${GREEN}[✔] Already redis${NC}\n"
        return
    fi

    if ! hasRedis; then
        installRedis
    fi
}

function purgeRedis() {
    if hasRedis; then
        uninstallRedis
    fi
}

function isRunningRedis() {
    [[ "$(redis-cli ping 2>&1 | grep -ic "Connection refused")" -eq "0" ]]
}

function startRedis() {
    if isRunningRedis; then
        printf "${GREEN}[✔] Already running redis${NC}\n"
        return
    fi

    printf "${BLUE}[-] Starting redis...${NC}\n"
    redis-server /usr/local/etc/redis.conf &
}
