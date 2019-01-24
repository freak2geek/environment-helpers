#!/usr/bin/env bash

# Load behavior of local `.envrc` files
function tryLoadEnvrc() {
	local current="${PWD}"

	# Look for the script and load it
	if [[ -f ./.envrc ]] && [[ "$current" != ~ ]]; then
		source ./.envrc
		LOADED_ENVRC+="$current"
	fi
}

# Wrapper of the custom cd to inject the load behavior
function custom_cd() {
	builtin cd $@
	tryLoadEnvrc ${*: -1:1}
}
alias cd='custom_cd'

tryLoadEnvrc
