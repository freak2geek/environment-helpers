#!/usr/bin/env bash

source "./src/npm.sh"

ENV_DEVELOPMENT='development'
ENV_PRODUCTION='production'

function bootProject() {
    local projectPath=${1-"."}
    PROJECT_NAME=$(getNpmPackageName)
    PROJECT_VERSION=$(getNpmPackageVersion)

    if [[ -d ${projectPath}/${APPS_PATH} ]]; then
        for dir in `find ${projectPath}/${APPS_PATH} -maxdepth 1 -type d`
        do
            if [[ -f ${dir}/package.json ]]; then
                packageName=$(getNpmPackageName ${dir}/package.json)
                packageVersion=$(getNpmPackageVersion ${dir}/package.json)
                localPackageName=$(echo ${packageName} | sedr 's/\-/_/g')
                localPackageName=$(echo ${localPackageName} | sedr 's/@//g')
                localPackageName=$(echo ${localPackageName} | sedr 's/\//_/g')
                localPackageName=$(echo ${localPackageName} | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/')
                eval "${localPackageName}_NAME=\"${packageName}\""
                eval "${localPackageName}_VERSION=\"${packageVersion}\""
                eval "${localPackageName}_APP=\"$(basename ${packageName})\""
                eval "${localPackageName}_PATH=\"${dir}\""
            fi
        done
    fi
}
