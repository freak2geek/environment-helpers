#!/usr/bin/env bash

source "./src/npm.sh"

ENV_DEVELOPMENT='development'
ENV_PRODUCTION='production'

function bootProject() {
    PROJECT_NAME=$(getNpmPackageName)
    PROJECT_VERSION=$(getNpmPackageVersion)

    if [[ -d ./${APPS_PATH} ]]; then
        for dir in `find ./${APPS_PATH} -type d -maxdepth 1`
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
                eval "${localPackageName}_PATH=\"${dir}\""
            fi
        done
    fi
}
