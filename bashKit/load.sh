#!/usr/bin/env bash

#
# Bash kit is a minimal collection of Bash functions used to assist in 
# writing more complex scripts.
bashKitLoad() {
  local tmpCurrentDirectoryPath="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}")"

  local it=""
  for it in $(find "${tmpCurrentDirectoryPath}" -mindepth 2 -type f -name "*.sh"); do
    . "${it}"
  done

  if [ "${1}" == "1" ]; then
    burlLiveTest
  fi
}
bashKitLoad "${1}"
unset bashKitLoad