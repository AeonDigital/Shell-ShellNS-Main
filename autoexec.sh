#!/usr/bin/env bash

if [ "${SHELLNS_TMP_PACKAGE_DIR_PATH}" != "" ]; then
  echo "[ x ] Error: ShellNS is already loaded!"
  exit 1
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
        echo "[ x ] Error: Cannot load the configuration file!"
        exit 1
      fi
    fi


    local pathToMainBootScripts="${SHELLNS_TMP_PACKAGE_DIR_PATH}/src/boot"
    local -A assocMapFunctionsToBootScript
    assocMapFunctionsToBootScript["shellNS_main_boot_dependencies"]="${pathToMainBootScripts}/dependencies.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_dialog"]="${pathToMainBootScripts}/dialog.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_executeScript"]="${pathToMainBootScripts}/executeScript.sh"
    assocMapFunctionsToBootScript["shellNS_main_boot_getFiles"]="${pathToMainBootScripts}/getFiles.sh"

    for funcName in "${!assocMapFunctionsToBootScript[@]}"; do
      if [ ! declare -F "${funcName}" > /dev/null ]; then
        . "${assocMapFunctionsToBootScript[${funcName}]}"
      fi
    done
  }



  shellNS_main_autoexec
  shellNS_main_package_entrypoint "${SHELLNS_TMP_PACKAGE_DIR_PATH}" "${1}" "${2}" "${3}" "${4}"
fi