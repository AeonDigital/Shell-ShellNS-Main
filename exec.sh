#!/usr/bin/env bash

#
# Execute action
#
# @param string $1
# Action to be executed.
#
# Choose one of:
# - load
# - shrink|pkg
#   can be used $2=1 to force update of Shell-BashKit-Shrink
#
# @param string $2
# optional. Complement arg.
execBashKit() {
  local action="${1:-load}"
  local arg1="${2}"

  local currentDirectoryPath="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}")"
  local projectName="${currentDirectoryPath##*/}"

  case "${action,,}" in 
    load)
      local it=""
      for it in $(find "${currentDirectoryPath}/src" -type f -name "*.sh" | sort); do
        . "${it}"
      done
      ;;

    shrink|pkg)
      local shrinkFile="${currentDirectoryPath}/package-shell-bashkit-shrink.sh"
      if [ ! -f "${shrinkFile}" ] || [ "${arg1}" == "1" ]; then
        local strGitRepoURL="https://raw.githubusercontent.com"
        local strOwner="AeonDigital"
        local strRepo="Shell-BashKit-Shrink"
        local tgtURL="${strGitRepoURL}/${strOwner}/${strRepo}/main/package-"${strRepo,,}".sh"
        
        echo "[ i ] Info: update '${strRepo}' package"
        echo "            from '${tgtURL}'"

        curl -o "${shrinkFile}" "${tgtURL}"
        if [ "$?" != "0" ]; then
          echo "[ x ] Error: fail on download of '${tgtURL}'" >&2
          return "1"
        fi

        echo "[ i ] Info: Create/Update '${shrinkFile}'"
      fi

      local codeNL=$'\n'
      local strShrinkHeader+="#${codeNL}"
      strShrinkHeader+="# mounted by Shell-BashKit-Shrink in "
      strShrinkHeader+=$(date +"%Y-%m-%d %H:%M:%S")
      strShrinkHeader+="${codeNL}${codeNL}"


      . "${shrinkFile}"
      shrinkPackage "${currentDirectoryPath}/src" "${currentDirectoryPath}/package-${projectName,,}.sh" "${strShrinkHeader}"
      ;;
  esac
}
execBashKit "${1}" "${2}"
unset execBashKit