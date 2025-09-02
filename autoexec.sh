#!/usr/bin/env bash

#
# Register all functions that has to be unseted after start ShellNS or 
# if has an error on boot.
declare -ga SHELLNS_TMP_UNSET_ON_END=()



#
# Unset all registered variables and functions.
#
# @return void
sparkFN_unsetOnEnd() {
  local it=""
  for it in "${SHELLNS_TMP_UNSET_ON_END[@]}"; do
    unset "${it}"
  done

  if [ "${SHELLNS_MAIN_LOAD_CONTROL}" != "1" ]; then
    unset "SHELLNS_MAIN_LOAD_CONTROL"
  fi
  unset "SHELLNS_TMP_UNSET_ON_END"
}
SHELLNS_TMP_UNSET_ON_END+=("sparkFN_unsetOnEnd")



#
# Print an error message to the standard output.
#
# @param string $1
# Message to print.
#
# @return string
sparFN_messageError() {
  echo "[ x ] Error: ${1}"
}
SHELLNS_TMP_UNSET_ON_END+=("sparFN_messageError")



#
# Load all scripts in the given array
#
# @param array $1
# Name of the array with the location of scripts to be loaded
# 
# @return status+string
sparkFN_loadScripts() {
  local arrayName="${1}"
  
  if [ "${arrayName}" == "" ] || ! [[ "$(declare -p "${arrayName}" 2> /dev/null)" == "declare -a"* ]]; then
    sparFN_messageError "Then given array not exists; Array : '${arrayName}'"
    return "1"
  fi


  local -n arrayObject="${arrayName}"
  if [ "${#arrayObject[@]}" == "0" ]; then
    sparFN_messageError "Then given array is empty; Array : '${arrayName}'"
    return "1"
  fi


  local scriptPath=""  
  for scriptPath in "${arrayObject[@]}"; do
    if [ ! -f "${scriptPath}" ] || [ "${scriptPath: -3}" != ".sh" ]; then
      sparFN_messageError "Script not found or not a '.sh' file; Path : '${scriptPath}'"
      return "1"
    fi
  done


  for scriptPath in "${arrayObject[@]}"; do
      . "${scriptPath}"
  done
  
  return "0"
}
SHELLNS_TMP_UNSET_ON_END+=("sparkFN_loadScripts")



#
# Interrupt if ShellNS has been loaded
if [ "${SHELLNS_MAIN_LOAD_CONTROL}" != "" ]; then
  sparFN_messageError "ShellNS is already loaded!"
  sparkFN_unsetOnEnd
  return "1"
fi
unset SHELLNS_MAIN_LOAD_CONTROL
declare -g SHELLNS_MAIN_LOAD_CONTROL="0"





#
# Path to this current directory
unset SHELLNS_TMP_CURRENT_DIR_PATH
declare -g SHELLNS_TMP_CURRENT_DIR_PATH="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}")"
SHELLNS_TMP_UNSET_ON_END+=("SHELLNS_TMP_CURRENT_DIR_PATH")



#
# Load the initial scripts to perform this boot
declare -a SHELLNS_TMP_BOOT_SCRIPTS=()
SHELLNS_TMP_UNSET_ON_END+=("SHELLNS_TMP_BOOT_SCRIPTS")

SHELLNS_TMP_BOOT_SCRIPTS+=("${SHELLNS_TMP_CURRENT_DIR_PATH}/config.sh")
SHELLNS_TMP_BOOT_SCRIPTS+=("${SHELLNS_TMP_CURRENT_DIR_PATH}/bashKit/00_load.sh")

for it in $(find "${SHELLNS_TMP_CURRENT_DIR_PATH}/src/boot" -type f -name "*.sh"); do
  SHELLNS_TMP_BOOT_SCRIPTS+=("${it}")
done



sparkFN_loadScripts "SHELLNS_TMP_BOOT_SCRIPTS"
if [ "$?" != "0" ]; then
  sparkFN_unsetOnEnd
  return "1"
fi



shellNS_main_boot_entrypoint "${SHELLNS_TMP_CURRENT_DIR_PATH}" "${1}" "${2}" "${3}" "${4}"; statusSet "$?"
sparkFN_unsetOnEnd
if [ $(statusGet) == "0" ]; then
  # Variables that´s must be readonly after loading the config.sh file.
  readonly SHELLNS_MAIN_DIR_PATH
  readonly SHELLNS_MAIN_INTERFACE_LOCALE
fi
return $(statusGet)