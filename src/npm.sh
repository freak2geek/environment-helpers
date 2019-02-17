#!/usr/bin/env bash

function getNpmPackageName() {
    packagePath=${1-'package.json'}
    cat ${packagePath} | grep name | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]'
}

function getNpmPackageVersion() {
    packagePath=${1-'package.json'}
    cat ${packagePath} | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]'
}
