#!/usr/bin/env bash

#
# Loads the dependencies currently registered and all 
# files from the current package.
#
# @param dirExistentFullPath $1
# Path to the root directory of the current package.
#
# @param bool $2
# When **1** will download all dependencies in stangalone mode.
#
# @return void
shellNS_main_boot_packageLoad() {
  local pathToCurrentPackageDir="${1}"
  local isRunningInStandaloneMode="${2}"

  if [ "${isRunningInStandaloneMode}" == "1" ]; then
    shellNS_main_boot_dependencies "1"
  fi

  local -a arrayPackageFiles=()
  shellNS_main_boot_getFiles "${pathToCurrentPackageDir}" "arrayPackageFiles" "load"

  local pathToTargetFile=""
  for pathToTargetFile in "${arrayPackageFiles[@]}"; do
    . "${pathToTargetFile}"
  done
}