#!/usr/bin/env bash

#
# Main SHELLNS configurations


#
# Path to the main directory of the SHELLNS packages if it is installed
unset SHELLNS_MAIN_DIR_PATH
declare -g SHELLNS_MAIN_DIR_PATH="${XDG_DATA_HOME}/shellns"
if [ "${XDG_DATA_HOME}" == "" ]; then
  declare -g SHELLNS_MAIN_DIR_PATH="${HOME}/.shellns"
fi


#
# Register the main interface locale.
if [ "${SHELLNS_MAIN_INTERFACE_LOCALE}" == "" ]; then
  declare -g SHELLNS_MAIN_INTERFACE_LOCALE="en-us"
fi

#
# Start the associative array that controls the external dependencies 
# of this package. Every command that´s not a bash native must be in this list
# Ex: curl; wget; grep... 
unset SHELLNS_MAIN_EXTERNAL_DEPENDENCIES
declare -gA SHELLNS_MAIN_EXTERNAL_DEPENDENCIES










#
# Package Config

#
# Start the associative array that controls the load status of each package.
unset SHELLNS_MAIN_PACKAGE_LOAD_STATUS
declare -gA SHELLNS_MAIN_PACKAGE_LOAD_STATUS



#
# Create dependencies list.
unset SHELLNS_MAIN_DEPENDENCIES_REPO_LIST
declare -gA SHELLNS_MAIN_DEPENDENCIES_REPO_LIST



#
# Register external dependencies.
SHELLNS_MAIN_EXTERNAL_DEPENDENCIES["curl"]="-"



#
# Inserts a new entry into the dependency list to be load.
#
# @param string $1
# URL to the Git repository of the package.
#
# @param string $2
# Vendor name.
#
# @param string $3
# Package name.
#
# @param string $3
# Main package namespace.
#
# @return void
shellNS_core_register_dependency() {
  echo "w"
  # local strPkgURL="${1}"
  # if [ "${strPkgURL}" == "" ]; then
  #   messageError "Invalid package URL!"
  #   return "1"
  # fi

  # local strPkgVendor="${2}"
  # if [ "${strPkgVendor}" == "" ]; then
  #   messageError "Invalid package vendor!"
  #   return "1"
  # fi

  # local strPkgName="${3}"
  # if [ "${strPkgName}" == "" ]; then
  #   messageError "Invalid package name!"
  #   return "1"
  # fi
  
  # local strPkgKey="${2}_${3}"
  # SHELLNS_MAIN_DEPENDENCIES_REPO_LIST["${strPkgKey}"]="${strPkgURL}"
}