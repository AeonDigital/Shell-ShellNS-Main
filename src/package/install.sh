#!/usr/bin/env bash

#
# Installs a new package compatible with SHELLNS and prepares it to be 
# available from the next session.
#
# @param string $1
# URL to the Git repository of the package.
#
# @return status
shellNS_main_package_install() {
  local strPkgRepoURL="${1%.git}"
  if [ "${strPkgRepoURL}" == "" ]; then
    messageError  "Repository URL is required!"
    return "1"
  fi

  if [ ! -d "${SHELLNS_MAIN_DIR_PATH}" ]; then
    messageError  "The ShellNS installation directory was not found. [ '${SHELLNS_MAIN_DIR_PATH}' ]"
    return "1"
  fi



  local -a arrPkgURLParts=()
  local strRepo=""
  local strVendor=""

  IFS='/' read -ra arrPkgURLParts <<< "${strPkgRepoURL}"
  strRepo="${arrPkgURLParts[-1]}"
  strVendor="${arrPkgURLParts[-2]}"



  local strMSG=""
  local strTypeBool="[ 'y/yes' | 'n/no' ]"


  strMSG=""
  strMSG+="The selected package will be installed in '${SHELLNS_MAIN_DIR_PATH}'.\n"
  strMSG+="Confirm to proceed:  ${strTypeBool}"
  promptQuestion "${strMSG}" "varIsStringBool" "varStringBoolToBool"; statusSet "$?"

  if [ $(statusGet) != "0" ]; then
    messageFail "Invalid entry option '${BASHKIT_CORE_DIALOG_PROMPT_RAW_INPUT}'"
    return "1"
  fi


  if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "0" ]; then
    messageFail "Action aborted by the user."
    return "1"
  fi


  if [ -d "${SHELLNS_INSTALL_DIRECTORY}/${strVendor}/${strRepo}" ]; then
    messageError "The '${strRepo}' repository is already installed.\nUse the 'update' command to update it."
    return "1"
  fi


  if [ ! -d "${SHELLNS_INSTALL_DIRECTORY}/${strVendor}" ]; then
    mkdir "${SHELLNS_INSTALL_DIRECTORY}/${strVendor}"

    if [ "$?" != "0" ]; then
      messageError "Failed to create directory '${strVendor}' to install the '${strRepo}' repository!\nPlease, check and try again."
      return "1"
    fi
  fi


  git -C "${SHELLNS_INSTALL_DIRECTORY}/${strVendor}" clone --depth 1 "${strPkgRepoURL}"

  if [ "$?" == "0" ]; then
    messageOk "Repo '${strRepo}' install sucessful!"
  else
    messageError "Fail on install the '${strRepo}' repository!\nPlease, check and try again."
    return "1"
  fi




  local strBashCmd=""
  strBashCmd+="#\n"
  strBashCmd+="# [[ ${strVendor^^}_${strRepo^^} ]]\n"
  strBashCmd+="shellNS_main_register_package_dependency \"${strPkgRepoURL}\"\n"

  strMSG+="The following code will be added to the end of your 'bashrc' [ in ${SHELLNS_BASHRC_LOCATION} ]\n\n"
  strMSG+="''' bashrc\n"
  strMSG+="${strBashCmd}"
  strMSG+="'''\n\n"
  strMSG+="Confirm to proceed: ${strTypeBool}"
  
  promptQuestion "${strMSG}" "varIsStringBool" "varStringBoolToBool"; statusSet "$?"


  if [ $(statusGet) != "0" ]; then
    messageFail "Invalid entry option '${BASHKIT_CORE_DIALOG_PROMPT_RAW_INPUT}'"
    return "1"
  fi

  if [ "${BASHKIT_CORE_DIALOG_PROMPT_INPUT}" == "0" ]; then
    messageOk "Aborted by user\nPlease enter manually so that the package starts with the next session."
    return "0"
  else
    local strCurrentBashRC=$(< "${SHELLNS_BASHRC_LOCATION}")

    if [[ ! "${strCurrentBashRC}" =~ \[\[\ ${strVendor^^}_${strRepo^^}\ \]\] ]]; then
      echo -e "\n\n${strBashCmd}" >> "${SHELLNS_BASHRC_LOCATION}"
      if [ "$?" != "0" ]; then
        messageError "Cannot append start code to your 'bashrc'\nPlease enter manually so that the package starts with the next session."
        return "1"
      fi
    fi
  fi

  messageOk "The installation was successful!!\nThe installed package will start from your next session."
}