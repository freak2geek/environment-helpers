#!/usr/bin/env bash

function preinstallLinux() {
    printf "${BLUE}[-] Pre-installing Linux...${NC}\n"
    apt-get install sudo
    sudo apt-get install -y build-essential netcat
}
