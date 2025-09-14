#!/usr/bin/env bash

#
# List all installed packages.
#
# @param bool $1
# Indicate whether or not to format the list to be displayed 
# in the terminal (default '1').
# 
# If it is not formatted, the data will be displayed following 
# the following structure:
# - <status> <vendor> <reponame> <repourl>
#
# Status will be 'i' (inactive) or 'a' (active)
#
# @return string
shellNS_main_package_list() {
  local boolFormat="${1}"
  if [ "${boolFormat}" != "0" ] && [ "${boolFormat}" != "1" ]; then
    boolFormat="1"
  fi

  local -a arrPackageVendor=()
  local -a arrPackageRepoName=()
  local -a arrPackageStatus=()
  local -a arrPackageRepoURL=()


  local strPackageVendor=""
  local strPackageRepoName=""
  local strPackageStatus=""
  local strPackageRepoURL=""

  local strPathVendor=""
  local strPathRepo=""
  local strPkgKey=""
  for strPathVendor in $(find "${SHELLNS_INSTALL_DIRECTORY}" -mindepth 1 -maxdepth 1 -type d | stringSort $'\n'); do
    strPackageVendor="${strPathVendor##*/}"

    for strPathRepo in $(find "${strPathVendor}" -mindepth 1 -maxdepth 1 -type d | stringSort $'\n'); do
      strPackageRepoName="${strPathRepo##*/}"

      strPkgKey="${strPackageVendor}_${strPackageRepoName}"
      strPackageStatus="${SHELLNS_MAIN_PACKAGE_STATUS[${strPkgKey}]}"
      strPackageRepoURL="${SHELLNS_MAIN_PACKAGE_DEPENDENCY[${strPkgKey}]}"

      if [ "${strPackageStatus}" == "1" ]; then
        strPackageStatus="a"
      else
        strPackageStatus="i"
      fi

      arrPackageVendor+=("${strPackageVendor}")
      arrPackageRepoName+=("${strPackageRepoName}")
      arrPackageStatus+=("${strPackageStatus}")
      arrPackageRepoURL+=("${strPackageRepoURL}")
    done
  done


  local i=""
  if [ "${boolFormat}" == "0" ]; then
    for i in "${!arrPackageStatus[@]}"; do
      echo "${arrPackageStatus[${i}]} ${arrPackageVendor[${i}]} ${arrPackageRepoName[${i}]} ${arrPackageRepoURL[${i}]}"
    done
  else
    local j=""
    local strCurrentVendor=""
    local arrVendorRepos=()
    local strUseStatus=""
    local codeColorNone="${BASHKIT_CORE_DIALOG_COLOR_NONE}"
    local codeColorActive="${BASHKIT_CORE_DIALOG_TYPE_COLOR["ok"]}"
    local codeColorInactive="${BASHKIT_CORE_DIALOG_TYPE_COLOR["warning"]}"
    for i in "${!arrPackageVendor[@]}"; do
      if [ "${strCurrentVendor}" != "${arrPackageVendor[${i}]}" ]; then
        strCurrentVendor="${arrPackageVendor[${i}]}"
        arrVendorRepos=()

        showTitle "${strCurrentVendor}"
      fi

      strUseStatus=""
      if [ "${arrPackageStatus[${i}]}" == "a" ]; then
        strUseStatus+="${codeColorActive}a${codeColorNone}"
      else
        strUseStatus+="${codeColorActive}i${codeColorNone}"
      fi

      arrVendorRepos+=("[ ${strUseStatus} ] ${arrPackageRepoName[${i}]}\n${arrPackageRepoURL[${i}]}")
      ((j = i + 1))
      if [ "${arrPackageVendor[${j}]}" != "" ] && [ "${arrPackageVendor[${j}]}" !=  "${strCurrentVendor}" ]; then
        showList "arrVendorRepos"
      fi
    done
  fi
}