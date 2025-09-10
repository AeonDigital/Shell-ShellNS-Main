#!/usr/bin/env bash

#
# Execute the target function from target script.
#
# @param fileExistentPath $1
# Path to target script.
#
# @param function $2
# Name of the target function.
#
# @return mixed
shellNS_main_boot_executeScript() {
  local tgtFile="${1}"
  local tgtFunctionName="${2}"
  shift
  shift

  if [ ! -f "${tgtFile}" ]; then
    local strMsg=""
    strMsg+="Script file does not exist.\n"
    strMsg+="**${tgtFile}**"

    shellNS_main_boot_dialog "error" "${strMsg}"
    return "1"
  fi

  . "${tgtFile}"
  $tgtFunctionName "$@"; statusSet "$?"
  unset "${tgtFunctionName}"
}