#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function hasZsh() {
    which zsh | grep -icq "[^not found]"
}

function hasOhMyZsh() {
    [[ -d "${HOME}/.oh-my-zsh" ]]
}

function hasZshrc() {
    [[ -f "${HOME}/.oh-my-zsh/custom/plugins/zshrc/zshrc.plugin.zsh" ]]
}

function hasZshAsDefault() {
  # Alternative method
  # [[ $(cat "${HOME}/.bashrc" | grep -ic 'export SHELL=$(which zsh)') -ne "0" ]]
  false
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
    if [[ $(cat /etc/shells | grep -ic "$(which zsh)") -eq "0" ]]; then
        which zsh | sudo tee -a /etc/shells
    fi
    chsh -s $(which zsh)
    # Alternative method
    # printf '\n export SHELL=$(which zsh)' >>~/.bashrc
    # printf '\n [[ -z "$ZSH_VERSION" ]] && exec "$SHELL" -l' >>~/.bashrc
}
