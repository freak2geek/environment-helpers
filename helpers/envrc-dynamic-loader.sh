#!/usr/bin/env bash

LOADED_ENVRC=()

# Load behavior of local `.envrc` files
function tryLoadEnvrc() {
	local current="${PWD}"

	# Check if the script from the new
	# path has already been loaded
	for i in "${LOADED_ENVRC[@]}"
	do
		if [[ "$i" == "${current}" ]]; then
			return;
		fi
	done

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
