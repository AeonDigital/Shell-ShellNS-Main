#!/usr/bin/env bash

#
# Extract the manuals from the source files.
# Store them in the 'src-manuals/en-us' folder.
#
# @return void
shellNS_main_extract_rawManuals() {
  local strDefaultManualDir="${SHELLNS_TMP_PACKAGE_DIR_PATH}/src-manuals/en-us"

  if [ -d "${strDefaultManualDir}" ]; then
    rm -rf "${strDefaultManualDir}"

    if [ -d "${strDefaultManualDir}" ]; then
      shellNS_main_boot_dialog "error" "Error on delete current 'src-manuals/en-us' directory."
    fi
  fi

  mkdir -p "${strDefaultManualDir}"
  if [ ! -d "${strDefaultManualDir}" ]; then
    shellNS_main_boot_dialog "error" "Error on create 'src-manuals/en-us' directory."
    return 1
  fi
  

  local scriptPath=""
  local codeNL=$'\n'

  for scriptPath in $(find "${SHELLNS_TMP_PACKAGE_DIR_PATH}/src" -type f -name "*.sh" ! -name "config.sh" ! -name "*_test.sh"); do
    local strTgtContent=""
    local isDocumentationLine="0"

    local strRawLine=""
    IFS=$'\n'
    while read -r strRawLine || [ -n "${strRawLine}" ]; do
      if [ "${isDocumentationLine}" == "0" ] && [ "${strTgtContent}" != "" ]; then
        break
      fi
      if [[ "${strRawLine}" == \#!* ]] || [[ ! "${strRawLine}" == \#* ]]; then
        isDocumentationLine="0"
        continue
      fi
      isDocumentationLine="1"


      if [ "${strRawLine:0:2}" == "# " ]; then
        strRawLine="${strRawLine:2}"
      elif [ "${strRawLine:0:1}" == "#" ]; then
        strRawLine="${strRawLine:1}"
      fi


      strTgtContent+="${strRawLine}${codeNL}"
    done < "${scriptPath}"
    unset IFS


    strTgtContent="${strTgtContent#"${strTgtContent%%[![:space:]]*}"}" # trim L
    strTgtContent="${strTgtContent%"${strTgtContent##*[![:space:]]}"}" # trim R
    
    # Create a file with the same name as the script in corresponding folder
    # inside 'src-manuals/en-us'
    local strRelativePath="${scriptPath#${SHELLNS_TMP_PACKAGE_DIR_PATH}/src/}"
    local strTgtFilePath="${strDefaultManualDir}/${strRelativePath}"
    local strTgtDirPath="$(dirname "${strTgtFilePath}")"
    if [ ! -d "${strTgtDirPath}" ]; then
      mkdir -p "${strTgtDirPath}"
    fi
    if [ ! -d "${strTgtDirPath}" ]; then
      shellNS_main_boot_dialog "error" "Error on create '${strTgtDirPath}' directory."
      return 1
    fi
    echo -n "${strTgtContent}" > "${strTgtFilePath/.sh/.man}"

  done
}
