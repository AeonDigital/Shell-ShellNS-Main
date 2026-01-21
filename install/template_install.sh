#!/usr/bin/env bash

declare -g SHELLNS_INSTALL_STATUS="0"
declare -g SHELLNS_INSTALL_DIRECTORY=""
declare -g SHELLNS_BASHRC_LOCATION=""
declare -g SHELLNS_TIP_TYPE_BOOL="[ 'y/yes' | 'n/no' ]"


#
# interrupt the installation
checkInstallFail() {
  if [ "${SHELLNS_INSTALL_STATUS}" != "0" ]; then
    echo ""
    echo -e "[ err ] Installation **FAIL** with status '${SHELLNS_INSTALL_STATUS}'"
  fi
}


#
# Download shrinked BachKit core
downloadBashKitDependency() {
  if [ ! -f "package-shell-bashkit.sh" ]; then
    local tgtURL="https://raw.githubusercontent.com/AeonDigital/Shell-BashKit/main/package-shell-bashkit.sh"
    curl -O "${tgtURL}"
    if [ "$?" != "0" ]; then
      SHELLNS_INSTALL_STATUS="1"

      echo -e "[ err ] Fail on download BashKit"
      return "${SHELLNS_INSTALL_STATUS}"
    fi
  fi
}
downloadBashKitDependency
checkInstallFail





if [ "${SHELLNS_INSTALL_STATUS}" == "0" ]; then
  preInstallCheck() {  
    local strMSG="BashKit was successfully downloaded."
    messageOk "${strMSG}"


    strMSG=""
    strMSG+="Do you want to continue? ${SHELLNS_TIP_TYPE_BOOL}"
    promptQuestion "${strMSG}" "varIsStringBool" "varStringBoolToBool"; statusSet "$?"

    if [ $(statusGet) != "0" ]; then
      SHELLNS_INSTALL_STATUS="1"

      messageFail "Invalid entry option '${BASHKIT_CORE_DIALOG_PROMPT_RAW_INPUT}'"
      return "${SHELLNS_INSTALL_STATUS}"
    fi

    if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "0" ]; then
      SHELLNS_INSTALL_STATUS="2"

      messageFail "Aborted by user"
      return "${SHELLNS_INSTALL_STATUS}"
    fi
  }
  . package-shell-bashkit.sh
  showTitle "Wellcome to ShellNS installer" "In the next steps, we will proceed with the installation"
  preInstallCheck
  showHSeparator
  
  checkInstallFail
fi


if [ "${SHELLNS_INSTALL_STATUS}" == "0" ]; then
  installStep1() {
    local strMSG=""
    if varIsCommand "curl"; then
      strMSG="curl ... found!"
      messageOk "${strMSG}"
    else
      SHELLNS_INSTALL_STATUS="10"

      messageError "curl ... not found!"
      return "${SHELLNS_INSTALL_STATUS}"
    fi

    if varIsCommand "git"; then
      strMSG="Git  ... found!"
      messageOk "${strMSG}"
    else
      SHELLNS_INSTALL_STATUS="11"

      messageError "Git  ... not found!"
      return "${SHELLNS_INSTALL_STATUS}"
    fi
  }
  showTitle "STEP 1" "Check dependencies"
  installStep1
  showHSeparator

  checkInstallFail
fi


if [ "${SHELLNS_INSTALL_STATUS}" == "0" ]; then
  installStep2() {
    local strMSG=""


    local strTargetInstallFullPath=""
    if [ "${XDG_DATA_HOME}" != "" ] && [ -d "${XDG_DATA_HOME}" ]; then
      strMSG=""
      strMSG+="Find XDG DATA HOME directory!\n"
      strMSG+="Please confirm if we can install ShellNS\n"
      strMSG+="in '${XDG_DATA_HOME}/shellns'. ${SHELLNS_TIP_TYPE_BOOL}"
      promptQuestion "${strMSG}" "varIsStringBool" "varStringBoolToBool"; statusSet "$?"


      if [ $(statusGet) != "0" ]; then
        SHELLNS_INSTALL_STATUS="20"

        messageFail "Invalid entry option '${BASHKIT_CORE_DIALOG_PROMPT_RAW_INPUT}'"
        return "${SHELLNS_INSTALL_STATUS}"
      else
        if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "1" ]; then
          strTargetInstallFullPath="${XDG_DATA_HOME}/shellns"
        fi
      fi
    fi



    if [ "${strTargetInstallFullPath}" == "" ]; then
      strMSG=""
      strMSG+="Entry the install directory"
      promptInput "${strMSG}"; statusSet "$?"


      BASHKIT_CORE_DIALOG_PROMPT_INPUT=$(stringTrim "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}")
      if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "" ]; then
        SHELLNS_INSTALL_STATUS="21"

        messageFail "Install directory is required"
        return "${SHELLNS_INSTALL_STATUS}"
      else
        strTargetInstallFullPath="${BASHKIT_CORE_DIALOG_PROMPT_INPUT/#\~/${HOME}}"
      fi
    fi



    if [ -d "${strTargetInstallFullPath}" ]; then
      strMSG=""
      strMSG+="Install directory already exists.\n"
      strMSG+="To proceed, it will be necessary to remove all your current content.\n"
      strMSG+="Do you confirm? ${SHELLNS_TIP_TYPE_BOOL}"

      promptQuestion "${strMSG}" "varIsStringBool" "varStringBoolToBool"; statusSet "$?"


      if [ $(statusGet) != "0" ]; then
        SHELLNS_INSTALL_STATUS="22"

        messageFail "Invalid entry option '${BASHKIT_CORE_DIALOG_PROMPT_RAW_INPUT}'"
        return "${SHELLNS_INSTALL_STATUS}"
      else
        if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "1" ]; then
          rm -rf "${strTargetInstallFullPath}"

          if [ -d "${strTargetInstallFullPath}" ]; then
            SHELLNS_INSTALL_STATUS="23"

            messageFail "Could not delete the directory. Please, check your permissions!"
            return "${SHELLNS_INSTALL_STATUS}"
          fi
        fi
      fi
    fi



    mkdir -p "${strTargetInstallFullPath}"
    if [ ! -d "${strTargetInstallFullPath}" ]; then
      SHELLNS_INSTALL_STATUS="24"

      messageFail "Could not create the install directory. Please, check your permissions!"
      return "${SHELLNS_INSTALL_STATUS}"
    fi



    SHELLNS_INSTALL_DIRECTORY="${strTargetInstallFullPath}"
  }
  showTitle "STEP 2" "Select install directory"
  installStep2
  showHSeparator

  checkInstallFail
fi


if [ "${SHELLNS_INSTALL_STATUS}" == "0" ]; then
  installStep3() {
    local strMSG=""


    local strPathToBashRC=""
    if [ -f "${HOME}/.bashrc" ]; then
      strPathToBashRC="${HOME}/.bashrc"
    elif [ "${XDG_CONFIG_HOME}" != "" ] && [ -f "${XDG_CONFIG_HOME}/bash/bashrc" ]; then
      strPathToBashRC="${XDG_CONFIG_HOME}/bash/bashrc"
    fi


    if [ "${strPathToBashRC}" == "" ]; then
      strMSG=""
      strMSG+="Please, entry the path to your bashrc"
      promptInput "${strMSG}"; statusSet "$?"


      BASHKIT_CORE_DIALOG_PROMPT_INPUT=$(stringTrim "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}")
      if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "" ]; then
        SHELLNS_INSTALL_STATUS="30"

        messageFail "Location of bashrc is required"
        return "${SHELLNS_INSTALL_STATUS}"
      else
        strPathToBashRC="${BASHKIT_CORE_DIALOG_PROMPT_INPUT/#\~/${HOME}}"

        if [ ! -f "${strPathToBashRC}" ]; then
          SHELLNS_INSTALL_STATUS="31"

          messageFail "Bashrc not found in the given location: '${strPathToBashRC}'."
          return "${SHELLNS_INSTALL_STATUS}"
        fi
      fi
    fi


    messageOk "bashrc location confirmed in '${strPathToBashRC}'"
    SHELLNS_BASHRC_LOCATION="${strPathToBashRC}"
  }
  showTitle "STEP 3" "Confirm 'bashrc' location"
  installStep3
  showHSeparator

  checkInstallFail
fi


if [ "${SHELLNS_INSTALL_STATUS}" == "0" ]; then
  installStep4() {
    local strMSG=""

    local -a arrRepo=()
    arrRepo+=("https://github.com/AeonDigital/Shell-BashKit.git")
    arrRepo+=("https://github.com/AeonDigital/Shell-BashKit-OOP.git")
    arrRepo+=("https://github.com/AeonDigital/Shell-BashKit-Shrink.git")

    arrRepo+=("https://github.com/AeonDigital/Shell-ShellNS-Main.git")

    
    strMSG="The following repos will be install in the selected directory:\n\n"
    strMSG+=$(codeNL=$'\n'; sep="${codeNL} - "; tmp="${arrRepo[@]}"; echo " - ${tmp// /${sep}}")
    strMSG+="\n\nDo you want to continue? ${SHELLNS_TIP_TYPE_BOOL}"
    promptQuestion "${strMSG}" "varIsStringBool" "varStringBoolToBool"; statusSet "$?"

    if [ $(statusGet) != "0" ]; then
      SHELLNS_INSTALL_STATUS="40"

      messageFail "Aborted by user"
      return "${SHELLNS_INSTALL_STATUS}"
    fi

    if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "1" ]; then
      local -a arrPkgURLParts=()
      local strRepo=""
      local strVendor=""

      local urlRepo=""
      for urlRepo in "${arrRepo[@]}"; do
        arrPkgURLParts=()
        IFS='/' read -ra arrPkgURLParts <<< "${urlRepo}"

        strRepo="${arrPkgURLParts[-1]}"
        strVendor="${arrPkgURLParts[-2]}"

        if [ ! -d "${SHELLNS_INSTALL_DIRECTORY}/${strVendor}" ]; then
          mkdir "${SHELLNS_INSTALL_DIRECTORY}/${strVendor}"

          if [ "$?" != "0" ]; then
            SHELLNS_INSTALL_STATUS="41"

            messageError "Failed to create directory '${strVendor}' to install the '${strRepo}' repository!\nPlease, check and try again."
            return "${SHELLNS_INSTALL_STATUS}"
          fi
        fi

        git -C "${SHELLNS_INSTALL_DIRECTORY}/${strVendor}" clone --depth 1 "${urlRepo}"

        if [ "$?" == "0" ]; then
          strMSG="Repo '${strRepo}' install sucessful!"
          messageOk "${strMSG}"
        else
          SHELLNS_INSTALL_STATUS="42"

          messageError "Fail on install the '${strRepo}' repository!\nPlease, check and try again."
          return "${SHELLNS_INSTALL_STATUS}"
        fi
      done
    fi
  }
  showTitle "STEP 4" "Clonning repos"
  installStep4
  showHSeparator

  checkInstallFail
fi


if [ "${SHELLNS_INSTALL_STATUS}" == "0" ]; then
  installStep5() {
    local strStartScript=""
    read -r -d '' strStartScript <<-"EOF"
			[[ template_start.sh ]]
		EOF


    strStartScript="${strStartScript/\[\[SHELLNS_BASHRC_LOCATION\]\]/${SHELLNS_BASHRC_LOCATION}}"


    echo "${strStartScript}" > "${SHELLNS_INSTALL_DIRECTORY}/start.sh"
    if [ "$?" != "0" ] || [ ! -f "${SHELLNS_INSTALL_DIRECTORY}/start.sh" ]; then
      messageError "Fail on create script '${SHELLNS_INSTALL_DIRECTORY}/start.sh'!\nPlease, check and try again."

      SHELLNS_INSTALL_STATUS="50"
      return "${SHELLNS_INSTALL_STATUS}"
    fi





    local strPackageLoadScript=""
    read -r -d '' strPackageLoadScript <<-"EOF"
			[[ template_package.sh ]]
		EOF


    echo "${strPackageLoadScript}" > "${SHELLNS_INSTALL_DIRECTORY}/packages.sh"
    if [ "$?" != "0" ] || [ ! -f "${SHELLNS_INSTALL_DIRECTORY}/packages.sh" ]; then
      messageError "Fail on create script '${SHELLNS_INSTALL_DIRECTORY}/packages.sh'!\nPlease, check and try again."

      SHELLNS_INSTALL_STATUS="51"
      return "${SHELLNS_INSTALL_STATUS}"
    fi
    
    
    
    
    local strConfigScript=""
    read -r -d '' strConfigScript <<-"EOF"
			[[ template_config.sh ]]
		EOF


    echo "${strConfigScript}" > "${SHELLNS_INSTALL_DIRECTORY}/config.sh"
    if [ "$?" != "0" ] || [ ! -f "${SHELLNS_INSTALL_DIRECTORY}/config.sh" ]; then
      messageError "Fail on create script '${SHELLNS_INSTALL_DIRECTORY}/config.sh'!\nPlease, check and try again."

      SHELLNS_INSTALL_STATUS="51"
      return "${SHELLNS_INSTALL_STATUS}"
    fi




    local strMSG=""
    local strStartCode=""
    strStartCode+="# [[ Load ShellNS ]]\n"
    strStartCode+=". ${SHELLNS_INSTALL_DIRECTORY}/start.sh\n"
    
    strMSG+="The following code will be added to the end of your 'bashrc' [ in ${SHELLNS_BASHRC_LOCATION} ]\n\n"
    strMSG+="''' bashrc\n"
    strMSG+="${strStartCode}"
    strMSG+="'''\n\n"
    strMSG+="Confirm to proceed: ${SHELLNS_TIP_TYPE_BOOL}"
    
    promptQuestion "${strMSG}" "varIsStringBool" "varStringBoolToBool"; statusSet "$?"


    if [ $(statusGet) != "0" ]; then
      SHELLNS_INSTALL_STATUS="52"

      messageFail "Invalid entry option '${BASHKIT_CORE_DIALOG_PROMPT_RAW_INPUT}'"
      return "${SHELLNS_INSTALL_STATUS}"
    fi

    if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "0" ]; then
      SHELLNS_INSTALL_STATUS="53"

      messageFail "Aborted by user"
      return "${SHELLNS_INSTALL_STATUS}"
    else
      local strCurrentBashRC=$(< "${SHELLNS_BASHRC_LOCATION}")

      if [[ ! "${strCurrentBashRC}" =~ \[\[\ Load\ ShellNS\ \]\] ]]; then
        echo -e "\n\n${strStartCode}" >> "${SHELLNS_BASHRC_LOCATION}"
        if [ "$?" == "0" ]; then
          strMSG="ShellNS start code append to your 'bashrc'"
          messageOk "${strMSG}"
        else
          SHELLNS_INSTALL_STATUS="54"

          messageError "Cannot append start code to your 'bashrc'\nPlease, check and try again."
          return "${SHELLNS_INSTALL_STATUS}"
        fi
      fi
    fi
  }
  showTitle "STEP 5" "Prepare start script"
  installStep5
  showHSeparator

  checkInstallFail
fi


if [ "${SHELLNS_INSTALL_STATUS}" == "0" ]; then
  showTitle "The installation was completed successfully!" "ShellNS will start automatically in your next session."
fi





#
# Remove trash and clean workspace
rm package-shell-bashkit.sh
unset SHELLNS_INSTALL_STATUS
unset  SHELLNS_INSTALL_DIRECTORY
unset  SHELLNS_BASHRC_LOCATION
unset  SHELLNS_TIP_TYPE_BOOL

unset checkInstallFail
unset downloadBashKitDependency
unset preInstallCheck
unset installStep1
unset installStep2
unset installStep3
unset installStep4
unset installStep5