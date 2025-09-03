#!/usr/bin/env bash

#
# Loads the dependencies and starts the package in the context of the shell.
#
# @param dirExistentFullPath $1
# Path to the root directory of the current package.
#
# @param bool $2
# When **1** will run this package in **local** mode and therefore will 
# download all dependencies in stangalone mode.
#
# @return void
shellNS_main_package_load() {
  local pathToCurrentPackageDir="${1}"

  if [ "${2}" == "1" ]; then
    shellNS_main_boot_dependencies "1"
  fi

  local -a arrayPackageFiles=()
  shellNS_main_boot_getFiles "${pathToCurrentPackageDir}" "arrayPackageFiles" "load"

  local pathToTargetFile=""
  for pathToTargetFile in "${arrayPackageFiles[@]}"; do
    . "${pathToTargetFile}"
  done
}