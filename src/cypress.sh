#!/usr/bin/env bash

function preinstallLinuxForCypress() {
    printf "${BLUE}[-] Pre-installing Linux for Cypress...${NC}\n"
    sudo apt-get install -y xvfb libgtk2.0-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2
}
