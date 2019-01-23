#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

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
