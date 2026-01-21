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

    prepare-install)
      loadWithIndentAndScapes() {
        local pathFile="${1}"
        local codeNL=$'\n'
        local codeIdent=$'\t\t\t'
        local strLine=""
        local strContent=""
        
        while IFS= read -r strLine; do
          if [ "${strLine}" != "" ]; then
            strLine="${codeIdent}${strLine}"
          fi
          strContent+="${strLine}${codeNL}"
        done < "${pathFile}"

        strContent="${strContent//\&/codeAMP}"
        strContent="${strContent//\$/codeDOLARSIGN}"
        strContent="${strContent//\\/codeSLASH}"

        echo "${strContent}"
      }
      replaceScapes() {
        local strContent="${1}"

        strContent="${strContent//codeDOLARSIGN/$}"
        strContent="${strContent//codeSLASH/\\}"
        strContent="${strContent//codeAMP/\&}"

        echo "${strContent}"

      }

      local codeIdent=$'\t\t\t'
      local strTemplateInstall=$(< "${currentDirectoryPath}/install/template_install.sh")
      local strTemplateStart=$(loadWithIndentAndScapes "${currentDirectoryPath}/install/template_start.sh")
      local strTemplatePackage=$(loadWithIndentAndScapes "${currentDirectoryPath}/install/template_package.sh")
      local strTemplateConfig=$(loadWithIndentAndScapes "${currentDirectoryPath}/install/template_config.sh")


      strTemplateInstall="${strTemplateInstall/${codeIdent}\[\[\ template_start\.sh\ \]\]/${strTemplateStart}}"
      strTemplateInstall="${strTemplateInstall//\[\[\ template_package\.sh\ \]\]/${strTemplatePackage}}"
      strTemplateInstall="${strTemplateInstall//\[\[\ template_config\.sh\ \]\]/${strTemplateConfig}}"
      strTemplateInstall=$(replaceScapes "${strTemplateInstall}")

      echo "${strTemplateInstall}" > "${currentDirectoryPath}/install.sh"
      ;;
  esac
}
execBashKit "${1}" "${2}"
unset execBashKit