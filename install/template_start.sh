#!/usr/bin/env bash

#
# Path to the main directory of the SHELLNS packages
unset SHELLNS_MAIN_DIR_PATH
declare -gr SHELLNS_MAIN_DIR_PATH="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}")"

#
# Path to the bashrc
unset SHELLNS_BASHRC_LOCATION
declare -gr SHELLNS_BASHRC_LOCATION="[[SHELLNS_BASHRC_LOCATION]]"

#
# Start the associative array that controls the external dependencies 
# of this package. Every command that's not a bash native must be in this list
# Ex: curl; wget; grep... 
unset SHELLNS_MAIN_EXTERNAL_DEPENDENCY
declare -gA SHELLNS_MAIN_EXTERNAL_DEPENDENCY

#
# List of packages to be loaded.
unset SHELLNS_MAIN_PACKAGE_LIST
declare -gA SHELLNS_MAIN_PACKAGE_LIST

#
# Status of installed packages.
unset SHELLNS_MAIN_PACKAGE_STATUS
declare -gA SHELLNS_MAIN_PACKAGE_STATUS

#
# Order in which the packages were declared so 
# that they are loaded in the same order. 
unset SHELLNS_MAIN_PACKAGE_LOAD_ORDER
declare -ga SHELLNS_MAIN_PACKAGE_LOAD_ORDER

#
# Start the associative array that controls the load status of each package.
unset SHELLNS_MAIN_PACKAGE_LOAD_STATUS
declare -gA SHELLNS_MAIN_PACKAGE_LOAD_STATUS

#
# Primary interface locale.
declare -g SHELLNS_MAIN_INTERFACE_LOCALE="en-us"





#
# Print a 'error' message.
#
# @param string $1
# Message to print.
#
# @return string
messageError() {
  echo ""
  echo -e "[ err ] ${1}" >&2
}
#
# Checks if the given name is a command.
#
# @param string $1
# Name of the command.
#
# return status
varIsCommand() {
  local commandName="${1}"

  if command -v $commandName > /dev/null 2>&1; then
    return "0"
  fi

  return "1"
}



#
# Inserts a new entry into the external dependency list.
#
# @param string $1
# Name of the command/application.
#
# @return status
shellNS_register_external_dependency() {
  local strCommandName="${1}"

  if [ "${strCommandName}" == "" ]; then
    messageError "required: command name"
    return "1"
  fi

  if ! varIsCommand "${strCommandName}"; then
    messageError "invalid: command name [ '${strCommandName}' ]"
    return "1"
  fi

  SHELLNS_MAIN_EXTERNAL_DEPENDENCY["${strCommandName}"]="-"
}



#
# Inserts a new entry into the package list.
#
# @param string $1
# URL to the Git repository of the package.
#
# @param bool $2
# Indicate the status of this repository. 
# If '1', it is active and will be loaded in the next session opened; 
# otherwise, it will be considered inactive.
#
# @return status
shellNS_register_package() {
  local strPkgRepoURL="${1%.git}"
  local boolPkgStatus="${2:-1}"
  if [ "${strPkgRepoURL}" == "" ]; then
    messageError "required: package repository URL"
    return "1"
  fi

  if [ "${boolPkgStatus}" != "0" ] && [ "${boolPkgStatus}" != "1" ]; then
    messageError "invalid: status definition [ '${boolPkgStatus}' ]"
    return "1"
  fi

  local -a arrPkgURLParts=()
  IFS='/' read -ra arrPkgURLParts <<< "${strPkgRepoURL}"

  local strRepo="${arrPkgURLParts[-1]}"
  local strVendor="${arrPkgURLParts[-2]}"
  local strPkgKey="${strVendor}_${strRepo}"

  if [[ ! -d "${SHELLNS_MAIN_DIR_PATH}/${strVendor}/${strRepo}" ]]; then
    messageError "Repository '${strRepo}' not found in '${SHELLNS_MAIN_DIR_PATH}/${strVendor}/${strRepo}'."
    return "1"
  fi

  if [[ ! -f "${SHELLNS_MAIN_DIR_PATH}/${strVendor}/${strRepo}/exec.sh" ]]; then
    messageError "File 'exec.sh' not found in '${strRepo}' repository."
    return "1"
  fi

  SHELLNS_MAIN_PACKAGE_LIST["${strPkgKey}"]="${strPkgRepoURL}"
  SHELLNS_MAIN_PACKAGE_STATUS["${strPkgKey}"]="${boolPkgStatus}"
  SHELLNS_MAIN_PACKAGE_LOAD_ORDER+=("${strPkgKey}")
}



#
# Load all scripts in the given array.
#
# @param array $1
# Name of the array with the location of scripts to be loaded
# 
# @return status+string
shellNS_start_loadFromArray() {
  local -n arrayObject="${1}"
  local scriptPath=""  

  for scriptPath in "${arrayObject[@]}"; do
    . "${scriptPath}"
  done

  return "0"
}



#
# Fills the control arrays with the full paths to the files corresponding to 
# all the scripts that should be loaded for the target package.
#
# @param dirExistentFullPath $1
# Path to the root directory of the target package.
#
# @return array[]
# The following arrays will be filled:
#
# - SHELLNS_MAIN_TMP_PATH_TO_CONFIG
# - SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_CONFIG
# - SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_FILES
# - SHELLNS_MAIN_TMP_PATH_TO_LOCALE_FILES
# - SHELLNS_MAIN_TMP_PATH_TO_NS_FILES
# - SHELLNS_MAIN_TMP_PATH_TO_AUTOEXEC_FILES
shellNS_start_retrieve_package_files() {
  local pathToCurrentPackageDir="${1}"

  #
  # Check for 'config.sh' file
  [[ -f "${pathToCurrentPackageDir}/config.sh" ]] && SHELLNS_MAIN_TMP_PATH_TO_CONFIG+=("${pathToCurrentPackageDir}/config.sh")

  #
  # Get 'config.sh' files in 'src' folder
  local it=""
  if [ -d "${pathToCurrentPackageDir}/src" ]; then
  for it in $(find "${pathToCurrentPackageDir}/src" -type f -name "config.sh"); do
      SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_CONFIG+=("${it}")
  done

  #
  # Grab the rest of the files.
  for it in $(find "${pathToCurrentPackageDir}/src" -type f -name "*.sh" ! -name "config.sh" ! -name "*_test.sh"); do
      SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_FILES+=("${it}")
  done
  fi



  #
  # Load the locale labels
  local strFullPathToLocaleFile="${pathToCurrentPackageDir}/locale/${SHELLNS_MAIN_INTERFACE_LOCALE}.sh"
  [[ -f "${strFullPathToLocaleFile}" ]] && SHELLNS_MAIN_TMP_PATH_TO_LOCALE_FILES+=("${strFullPathToLocaleFile}")

  #
  # Check for 'ns.sh' file
  [[ -f "${pathToCurrentPackageDir}/ns.sh" ]] && SHELLNS_MAIN_TMP_PATH_TO_NS_FILES+=("${pathToCurrentPackageDir}/ns.sh")

  #
  # Check for 'autoexec.sh' file
  [[ -f "${pathToCurrentPackageDir}/autoexec.sh" ]] && SHELLNS_MAIN_TMP_PATH_TO_AUTOEXEC_FILES+=("${pathToCurrentPackageDir}/autoexec.sh")
}



#
# Load all registered packages
#
# @return void
shellNS_start_packages() {
  #
  # Register all packages to be loaded.
  . "${SHELLNS_MAIN_DIR_PATH}/packages.sh"
  [[ "$?" != "0" ]] && return "1"


  local it=""
  for it in "${SHELLNS_START_EXTERNAL_DEPENDENCY[@]}"; do
    shellNS_register_external_dependency "${it}"
    [[ "$?" != "0" ]] && return "1"
  done

  local -a arrParam=()
  for it in "${SHELLNS_START_PACKAGE_LIST[@]}"; do
    arrParam=(${it})
    shellNS_register_package "${arrParam[@]}"
    [[ "$?" != "0" ]] && return "1"
  done



  local -a arrPkgURLParts=()
  local strRepo=""
  local strVendor=""

  local strPkgKey=""
  for strPkgKey in "${SHELLNS_MAIN_PACKAGE_LOAD_ORDER[@]}"; do
  if [ "${SHELLNS_MAIN_PACKAGE_STATUS[${strPkgKey}]}" == "1" ]; then
    arrPkgURLParts=()
    IFS='/' read -ra arrPkgURLParts <<< "${SHELLNS_MAIN_PACKAGE_LIST[${strPkgKey}]}"

    strRepo="${arrPkgURLParts[-1]}"
    strVendor="${arrPkgURLParts[-2]}"

    shellNS_start_retrieve_package_files "${SHELLNS_MAIN_DIR_PATH}/${strVendor}/${strRepo}"
  fi
  done


  shellNS_start_loadFromArray "SHELLNS_MAIN_TMP_PATH_TO_CONFIG"
  shellNS_start_loadFromArray "SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_CONFIG"
  shellNS_start_loadFromArray "SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_FILES"
  shellNS_start_loadFromArray "SHELLNS_MAIN_TMP_PATH_TO_LOCALE_FILES"
  shellNS_start_loadFromArray "SHELLNS_MAIN_TMP_PATH_TO_NS_FILES"
  shellNS_start_loadFromArray "SHELLNS_MAIN_TMP_PATH_TO_AUTOEXEC_FILES"


  #
  # Load custom configuration
  . "${SHELLNS_MAIN_DIR_PATH}/config.sh"
}



#
# Load registered packages
declare -ga SHELLNS_MAIN_TMP_PATH_TO_CONFIG=()
declare -ga SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_CONFIG=()
declare -ga SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_FILES=()
declare -ga SHELLNS_MAIN_TMP_PATH_TO_LOCALE_FILES=()
declare -ga SHELLNS_MAIN_TMP_PATH_TO_NS_FILES=()
declare -ga SHELLNS_MAIN_TMP_PATH_TO_AUTOEXEC_FILES=()

shellNS_start_packages

unset SHELLNS_MAIN_TMP_PATH_TO_CONFIG
unset SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_CONFIG
unset SHELLNS_MAIN_TMP_PATH_TO_SCRIPT_FILES
unset SHELLNS_MAIN_TMP_PATH_TO_LOCALE_FILES
unset SHELLNS_MAIN_TMP_PATH_TO_NS_FILES
unset SHELLNS_MAIN_TMP_PATH_TO_AUTOEXEC_FILES