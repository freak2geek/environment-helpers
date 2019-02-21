#!/usr/bin/env bash

# Load behavior of local `.envrc` files
function tryLoadEnvrc() {
	local current="${PWD}"
	local maxDepth=20
	local depth=0
    while [[ ${current} != ~ ]] && [[ ${current} != "/" ]] && [[ ${depth} -lt ${maxDepth} ]]
    do
        envrcPath=${current}/.envrc
        # Look for the script and load it
        if [[ -f ${envrcPath} ]]; then
            source ${envrcPath}
        fi
        current="$(dirname "${current}")"
        depth=$((${depth}+1))
    done
}

# Wrapper of the custom cd to inject the load behavior
function custom_cd() {
	builtin cd $@
	tryLoadEnvrc ${*: -1:1}
}
alias cd='custom_cd'

tryLoadEnvrc
