#!/usr/bin/env bash

#
# Print an error message to the standard output.
#
# @param string $1
# Message to print.
#
# @return string
messageError() {
  echo "[ x ] Error: ${1}"
}



if [ "${SHELLNS_TMP_PACKAGE_DIR_PATH}" != "" ]; then
  messageError "ShellNS is already loaded!"
  return "1"
else
  #
  # Path to the temporary directory of this package.
  unset SHELLNS_TMP_PACKAGE_DIR_PATH
  declare -g SHELLNS_TMP_PACKAGE_DIR_PATH="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}")"



  #
  # Main autoexec script that is called when the package is loaded.
  #
  # @return void
  shellNS_main_autoexec() {
    if [ "${SHELLNS_MAIN_DIR_PATH}" == "" ]; then
      if [ -f "${SHELLNS_TMP_PACKAGE_DIR_PATH}/config.sh" ]; then
        . "${SHELLNS_TMP_PACKAGE_DIR_PATH}/config.sh"
      else
        messageError "Cannot load the configuration file '${SHELLNS_TMP_PACKAGE_DIR_PATH}/config.sh'!"
        return "1"
      fi

      if [ -f "${SHELLNS_TMP_PACKAGE_DIR_PATH}/core.sh" ]; then
        . "${SHELLNS_TMP_PACKAGE_DIR_PATH}/core.sh"
      else
        messageError "Cannot load the core functions in '${SHELLNS_TMP_PACKAGE_DIR_PATH}/core.sh'!"
        return "1"
      fi
    fi


    local pathToMainBootScripts="${SHELLNS_TMP_PACKAGE_DIR_PATH}/src/boot"
    local -A assocMapFunctionsToBootScript
    assocMapFunctionsToBootScript["shellNS_main_boot_dependencies"]="${pathToMainBootScripts}/dependencies.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_dialog"]="${pathToMainBootScripts}/dialog.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_entrypoint"]="${pathToMainBootScripts}/entrypoint.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_executeScript"]="${pathToMainBootScripts}/executeScript.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_getFiles"]="${pathToMainBootScripts}/getFiles.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_packageLoad"]="${pathToMainBootScripts}/packageLoad.sh"


    local funcName=""
    local funcScript=""
    for funcName in "${!assocMapFunctionsToBootScript[@]}"; do
      funcScript="${assocMapFunctionsToBootScript[${funcName}]}"
      if [ ! -f "${funcScript}" ]; then
        messageError "Cannot find script for function '${funcName}' in '${funcScript}' location!"
        return "1"
      fi

      . "${funcScript}"
      if declare -F "${funcName}" > /dev/null; then
        continue
      else
        messageError "function ${funcName} not found in ${funcScript} script!"
        return "1"
      fi
    done

    #shellNS_main_boot_entrypoint "${SHELLNS_TMP_PACKAGE_DIR_PATH}" "${1}" "${2}" "${3}" "${4}"

    # Variables that´s must be readonly after loading the config.sh file.
    #readonly SHELLNS_MAIN_DIR_PATH
    #readonly SHELLNS_MAIN_INTERFACE_LOCALE
  }
  
  shellNS_main_autoexec "${1}" "${2}" "${3}" "${4}"
  return "$?"
fi