#!/usr/bin/env bash

#
# Main SHELLNS configurations


#
# Path to the main directory of the SHELLNS packages.
unset SHELLNS_MAIN_DIR_PATH
declare -g SHELLNS_MAIN_DIR_PATH="${XDG_DATA_HOME}/shellns"
if [ "${XDG_DATA_HOME}" == "" ]; then
  declare -g SHELLNS_MAIN_DIR_PATH="${HOME}/.shellns"
fi
readonly SHELLNS_MAIN_DIR_PATH


#
# Register the main interface locale.
if [ "${SHELLNS_MAIN_INTERFACE_LOCALE}" == "" ]; then
  readonly SHELLNS_MAIN_INTERFACE_LOCALE="en-us"
fi

#
# Start the associative array that controls the external dependencies of this package.
unset SHELLNS_MAIN_EXTERNAL_DEPENDENCIES
declare -gA SHELLNS_MAIN_EXTERNAL_DEPENDENCIES


#
# Start the associative array that maps functions to their manual files.
unset SHELLNS_MAIN_MAPP_FUNCTION_TO_MANUAL
declare -gA SHELLNS_MAIN_MAPP_FUNCTION_TO_MANUAL

#
# Start the associative array that maps namespaces to their main function.
unset SHELLNS_MAIN_MAPP_NAMESPACE_TO_FUNCTION
declare -gA SHELLNS_MAIN_MAPP_NAMESPACE_TO_FUNCTION



#
# Mantain the last registered result status.
unset SHELLNS_LAST_RETURN_STATUS
declare -g SHELLNS_LAST_RETURN_STATUS=""
#
# Store the result status for lazy comparison.
#
# @param int $1
# Status code to store.
#
# @return void
statusSet() {
  SHELLNS_LAST_RETURN_STATUS="${1}"
}
#
# Get the last stored status code.
#
# @return int
statusGet() {
  echo -ne "${SHELLNS_LAST_RETURN_STATUS}"
}





#
# Package Config

#
# Start the associative array that controls the load status of each package.
unset SHELLNS_MAIN_PACKAGE_LOAD_STATUS
declare -gA SHELLNS_MAIN_PACKAGE_LOAD_STATUS



#
# Register external dependencies.
SHELLNS_MAIN_EXTERNAL_DEPENDENCIES["curl"]="-"



#
# Inserts a new entry into the dependency list.
#
# @param string $1
# Package name.
#
# @param string $2
# Short name.
#
# @return void
shellNS_standalone_install_set_dependency() {
  local strDownloadFileName="shellns_${2,,}_standalone.sh"
  local strPkgStandaloneURL="https://raw.githubusercontent.com/AeonDigital/${1}/refs/heads/main/standalone/package.sh"
  SHELLNS_MAIN_DEPENDENCIES["${strDownloadFileName}"]="${strPkgStandaloneURL}"
}

#
# Create dependencies list.
unset SHELLNS_MAIN_DEPENDENCIES
declare -gA SHELLNS_MAIN_DEPENDENCIES
