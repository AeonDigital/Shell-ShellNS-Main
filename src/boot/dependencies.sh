#!/usr/bin/env bash

#
# Download and load dependencies to current shell context.
#
# @param bool $1
# When **1** will download all dependencies in standalone mode.
#
# @return status+string
shellNS_main_boot_dependencies() {
  if ! varIsAssoc "SHELLNS_MAIN_DEPENDENCIES_REPO_LIST" && varIsArrayExistsAndIsEmpty "SHELLNS_MAIN_DEPENDENCIES_REPO_LIST"; then
    return "0"
  fi

  local boolLoadDependencies="${1}"
  if [ "${boolLoadDependencies}" != "1" ]; then
    boolLoadDependencies="0"
  fi


  local pkgFileName=""
  local pkgSourceURL=""
  local pgkLoadStatus=""


  #
  # Download dependencies
  for pkgFileName in "${!SHELLNS_MAIN_DEPENDENCIES_REPO_LIST[@]}"; do
    pgkLoadStatus="${SHELLNS_MAIN_PACKAGE_LOAD_STATUS[${pkgFileName}]}"
    if [ "${pgkLoadStatus}" == "" ]; then pgkLoadStatus="0"; fi
    if [ "${pgkLoadStatus}" == "ready" ] || [ "${pgkLoadStatus}" -ge "1" ]; then
      continue
    fi

    if [ ! -f "${pkgFileName}" ]; then
      pkgSourceURL="${SHELLNS_MAIN_DEPENDENCIES_REPO_LIST[${pkgFileName}]}"

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

    chmod +x "${pkgFileName}"; statusSet "$?"
    if [ $(statusGet) != "0" ]; then
      local strMsg=""
      strMsg+="Could not give execute permission to script:\n"
      strMsg+="FILE: **${pkgFileName}**\n\n"
      strMsg+="This execution was aborted."

      shellNS_main_boot_dialog "error" "${strMsg}"
      return $(statusGet)
    fi

    SHELLNS_MAIN_PACKAGE_LOAD_STATUS["${pkgFileName}"]="1"
  done



  #
  # Load dependencies
  if [ "${boolLoadDependencies}" == "1" ]; then
    for pkgFileName in "${!SHELLNS_MAIN_DEPENDENCIES_REPO_LIST[@]}"; do
      pgkLoadStatus="${SHELLNS_MAIN_PACKAGE_LOAD_STATUS[${pkgFileName}]}"
      if [ "${pgkLoadStatus}" == "ready" ]; then
        continue
      fi

      . "${pkgFileName}"; statusSet "$?"
      if [ $(statusGet) != "0" ]; then
        local strMsg=""
        strMsg+="An unexpected error occurred while load script:\n"
        strMsg+="FILE: **${pkgFileName}**\n\n"
        strMsg+="This execution was aborted."

        shellNS_main_boot_dialog "error" "${strMsg}"
        return $(statusGet)
      fi

      SHELLNS_MAIN_PACKAGE_LOAD_STATUS["${pkgFileName}"]="ready"
    done
  fi

   return "0"
}