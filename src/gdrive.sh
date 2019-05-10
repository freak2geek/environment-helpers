#!/usr/bin/env bash

source "./src/constants.sh"
source "./src/helpers.sh"

function downloadFromGoogleDrive() {
    gDriveId="${1}"
    gDriveExtension="${2-"tmp"}"
    gDriveFilename=${3-"${gDriveId}.${gDriveExtension}"}

    if [[ -z ${gDriveId} ]]; then
        printf "${RED} Please, provide the id of the Google Drive file.${NC}\n"
        return
    fi

    curl -c /tmp/cookie -s -L "https://drive.google.com/uc?export=download&id=${gDriveId}" > /dev/null
    curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' /tmp/cookie`&id=${gDriveId}" -o /tmp/${gDriveFilename}
}
