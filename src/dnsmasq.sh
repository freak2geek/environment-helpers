#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

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
        rm /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
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
    [[ -d "/etc/resolver/${DNSMASQ_DOMAIN}" ]] && sudo rm "/etc/resolver/${DNSMASQ_DOMAIN}"
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
