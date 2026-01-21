#!/usr/bin/env bash


#
# External commands required for the activation of the packages.. 
unset SHELLNS_START_EXTERNAL_DEPENDENCY
declare -ga SHELLNS_START_EXTERNAL_DEPENDENCY=()
SHELLNS_START_EXTERNAL_DEPENDENCY+=("curl")
SHELLNS_START_EXTERNAL_DEPENDENCY+=("git")





#
# List of all packages to be load in the bash sessions
# Use "1" and "0" to indicate when a package is active or inactive 
unset SHELLNS_START_PACKAGE_LIST
declare -ga SHELLNS_START_PACKAGE_LIST=()
SHELLNS_START_PACKAGE_LIST+=("https://github.com/AeonDigital/Shell-BashKit 1")
SHELLNS_START_PACKAGE_LIST+=("https://github.com/AeonDigital/Shell-BashKit-OOP 1")
SHELLNS_START_PACKAGE_LIST+=("https://github.com/AeonDigital/Shell-BashKit-Shrink 1")
SHELLNS_START_PACKAGE_LIST+=("https://github.com/AeonDigital/Shell-ShellNS-Main 1")