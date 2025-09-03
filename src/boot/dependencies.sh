#!/usr/bin/env bash

#
# Download and load dependencies to current shell context.
#
# @param bool $1
# If **1** load all dependencies after download.
#
# @return status+string
shellNS_main_boot_dependencies() {
  if [[ "$(declare -p "SHELLNS_MAIN_DEPENDENCIES" 2> /dev/null)" != "declare -A"* ]] || [ "${#SHELLNS_MAIN_DEPENDENCIES[@]}" == "0" ]; then
    return "0"
  fi


  local pkgFileName=""
  local pkgSourceURL=""
  local pgkLoadStatus=""


  #
  # Download dependencies
  for pkgFileName in "${!SHELLNS_MAIN_DEPENDENCIES[@]}"; do
    pgkLoadStatus="${SHELLNS_MAIN_PACKAGE_LOAD_STATUS[${pkgFileName}]}"
    if [ "${pgkLoadStatus}" == "" ]; then pgkLoadStatus="0"; fi
    if [ "${pgkLoadStatus}" == "ready" ] || [ "${pgkLoadStatus}" -ge "1" ]; then
      continue
    fi

    if [ ! -f "${pkgFileName}" ]; then
      pkgSourceURL="${SHELLNS_MAIN_DEPENDENCIES[${pkgFileName}]}"

      curl -o "${pkgFileName}" "${pkgSourceURL}"
      if [ ! -f "${pkgFileName}" ]; then
        local strMsg=""
        strMsg+="An error occurred while downloading a dependency.\n"
        strMsg+="URL: **${pkgSourceURL}**\n\n"
        strMsg+="This execution was aborted."

        shellNS_main_boot_dialog "error" "${strMsg}"
        return "1"
      fi
    fi

    chmod +x "${pkgFileName}"; setReturn $?
    if [ "$?" != "0" ]; then
      local strMsg=""
      strMsg+="Could not give execute permission to script:\n"
      strMsg+="FILE: **${pkgFileName}**\n\n"
      strMsg+="This execution was aborted."

      shellNS_main_boot_dialog "error" "${strMsg}"
      return "1"
    fi

    SHELLNS_MAIN_PACKAGE_LOAD_STATUS["${pkgFileName}"]="1"
  done



  #
  # Load dependencies
  if [ "${1}" == "1" ]; then
    for pkgFileName in "${!SHELLNS_MAIN_DEPENDENCIES[@]}"; do
      pgkLoadStatus="${SHELLNS_MAIN_PACKAGE_LOAD_STATUS[${pkgFileName}]}"
      if [ "${pgkLoadStatus}" == "ready" ]; then
        continue
      fi

      . "${pkgFileName}"
      if [ "$?" != "0" ]; then
        local strMsg=""
        strMsg+="An unexpected error occurred while load script:\n"
        strMsg+="FILE: **${pkgFileName}**\n\n"
        strMsg+="This execution was aborted."

        shellNS_main_boot_dialog "error" "${strMsg}"
        return "1"
      fi

      SHELLNS_MAIN_PACKAGE_LOAD_STATUS["${pkgFileName}"]="ready"
    done
  fi

   return "0"
}