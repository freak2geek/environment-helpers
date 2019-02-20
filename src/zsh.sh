#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"
source "./src/brew.sh"

function hasZsh() {
    hasBrew && [[ "$(brew ls zsh 2>&1 | grep -ic "No such keg")" -eq "0" ]]
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
