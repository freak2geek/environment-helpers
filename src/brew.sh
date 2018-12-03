#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

BREW_PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
BREW_UMASK="umask 002"

function hasBrew() {
    which brew | grep -icq "[^not found]"
}

function isBrewPathConfigured() {
    cat ~/.bashrc | grep -icq "${BREW_PATH}"
}

function isBrewUmaskConfigured() {
    cat ~/.bashrc | grep -icq "${BREW_UMASK}"
}

function isBrewConfigured() {
   isBrewPathConfigured && isBrewUmaskConfigured
}

function installBrew() {
    printf "\n${BLUE}[-] Installing brew...${NC}\n"
    sudo apt-get install -y --no-install-recommends build-essential curl file git
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    brew install gcc
}

function configureBrew() {
    tryConfigureBashrc

    printf "\n${BLUE}[-] Configuring brew...${NC}\n"

    if ! isBrewPathConfigured; then
        echo "export PATH='${BREW_PATH}'":'"$PATH"' >>~/.bashrc
        export PATH="${BREW_PATH}:$PATH"
    fi

    if ! isBrewUmaskConfigured; then
        echo ${BREW_UMASK} >>~/.bashrc
        eval ${BREW_UMASK}
    fi
}

function tryInstallBrew() {
    if hasBrew; then
        printf "\n${GREEN}[✔] Already brew${NC}\n"
    fi

    if ! hasBrew && [[ "$OSTYPE" == "linux-gnu" ]]; then
        installBrew
    fi

    if ! isBrewConfigured; then
        configureBrew
    fi
}

function uninstallBrew() {
    if ! hasRuby; then
        sudo apt-get install -y --no-install-recommends ruby
    fi
    if hasBrew; then
        printf "\n${BLUE}[-] Uninstall brew...${NC}\n"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/uninstall)"
    fi
    test -e /home/linuxbrew/.linuxbrew/bin/brew && brew prune
    sed -i '/linuxbrew/d' ~/.bashrc
    sed -i "/${BREW_UMASK}/d" ~/.bashrc
    test -d /home/linuxbrew/.linuxbrew/bin && rm -R /home/linuxbrew/.linuxbrew/bin
    test -d /home/linuxbrew/.linuxbrew/lib && rm -R /home/linuxbrew/.linuxbrew/lib
    test -d /home/linuxbrew/.linuxbrew/share && rm -R /home/linuxbrew/.linuxbrew/share
}

function tryUninstallBrew() {
    uninstallBrew
}
