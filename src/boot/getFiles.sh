#!/usr/bin/env bash

#
# Selects all the files that are part of the package and fills the indicated
# array with the full path with each one.
#
# @param dirExistentFullPath $1
# Path to the root directory of the current package.
#
# @param array $2
# Name of the array that will be populated with the files that are part of
# the package.
#
# @param string $3
# Type of execution. 
#
# @return array
shellNS_main_boot_getFiles() {
  local pathToCurrentPackageDir="${1}"
  local -n arrTargetFiles="${2}"
  local strExecType="${3}"

  local tmpIterator=""



  #
  # If you are mounting a standalone version
  # if [ "${strExecType}" == "export" ]; then
  #   local tgtDir="${SHELLNS_TMP_PRELOAD_DIR_PATH}"
  #   if [ -f "${tgtDir}/config.sh" ] && [ -f "${tgtDir}/dialog.sh" ] && [ -f "${tgtDir}/dependencies.sh" ] && [ -f "${tgtDir}/autoexec.sh" ]; then
  #     arrTargetFiles+=("${tgtDir}/config.sh")
  #     arrTargetFiles+=("${tgtDir}/dialog.sh")
  #     arrTargetFiles+=("${tgtDir}/dependencies.sh")
  #     arrTargetFiles+=("${tgtDir}/autoexec.sh")
  #   fi
  # fi



  
  #
  # Get all unit tests in this package.
  if [ "${strExecType}" == "utest" ]; then
    for tmpIterator in $(find "${pathToCurrentPackageDir}" -name "*_test.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done
  fi



  #
  # Checks for dependencies on specific functions
  if [ -d "${pathToCurrentPackageDir}/_" ]; then
    for tmpIterator in $(find "${pathToCurrentPackageDir}/_" -type f -name "*.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done
  fi

  #
  # Check for 'config.sh' file
  if [ -f "${pathToCurrentPackageDir}/config.sh" ]; then
    arrTargetFiles+=("${pathToCurrentPackageDir}/config.sh")
  fi

  #
  # Get 'config.sh' files in 'src' folder
  if [ -d "${pathToCurrentPackageDir}/src" ]; then
    for tmpIterator in $(find "${pathToCurrentPackageDir}/src" -type f -name "config.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done

    #
    # Grab the rest of the files.
    for tmpIterator in $(find "${pathToCurrentPackageDir}/src" -type f -name "*.sh" ! -name "config.sh" ! -name "*_test.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done
  fi



  #
  # Load the locale labels and adjusts
  local strFullPathToLocaleFile="${pathToCurrentPackageDir}/locale/${SHELLNS_MAIN_INTERFACE_LOCALE}.sh"
  if [ -f "${strFullPathToLocaleFile}" ]; then
    arrTargetFiles+=("${strFullPathToLocaleFile}")
  fi


  #
  # Check for 'ns.sh' file
  if [ -f "${pathToCurrentPackageDir}/ns.sh" ]; then
    arrTargetFiles+=("${pathToCurrentPackageDir}/ns.sh")
  fi


  #
  # Check for 'autoexec.sh' file
  if [ -f "${pathToCurrentPackageDir}/autoexec.sh" ]; then
    arrTargetFiles+=("${pathToCurrentPackageDir}/autoexec.sh")
  fi
}
