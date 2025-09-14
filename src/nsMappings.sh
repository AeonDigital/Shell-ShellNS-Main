#!/usr/bin/env bash

#
# Start the associative array that maps functions to their manual files.
unset SHELLNS_MAIN_MAPP_FUNCTION_TO_MANUAL
declare -gA SHELLNS_MAIN_MAPP_FUNCTION_TO_MANUAL

#
# Start the associative array that maps namespaces to their main function.
unset SHELLNS_MAIN_MAPP_NAMESPACE_TO_FUNCTION
declare -gA SHELLNS_MAIN_MAPP_NAMESPACE_TO_FUNCTION



#
# Generate the 'ns.sh' file that contains the mapping of namespaces to
# their respective manual files.
#
# @return void
shellNS_main_extract_nsMappings() {
  local strFunctionsDirPath="${SHELLNS_TMP_PACKAGE_DIR_PATH}/src"
  local srcScriptPath=""
  local strRawLine=""
  
  local strFunctionName=""
  local strFunctionNamespace=""
  local strFunctionScriptRelativePath=""

  local strManualRelativePath=""

  local str_FUNCTION_TO_MANUAL=""
  local str_NAMESPACE_TO_FUNCTION=""

  for srcScriptPath in $(find "${strFunctionsDirPath}" -type f -name "*.sh" | stringSort $'\n'); do
    
    IFS=$'\n'
    while read -r strRawLine || [ -n "${strRawLine}" ]; do
      if [[ "${strRawLine}" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\)[[:space:]]*\{ ]]; then
        strFunctionName="${BASH_REMATCH[1]}"
        break
      fi
    done < "${srcScriptPath}"
    unset IFS

    strFunctionScriptRelativePath="${srcScriptPath#${strFunctionsDirPath}/}"
    strManualRelativePath="${strFunctionScriptRelativePath:: -3}.man"
    
    strFunctionNamespace="${strFunctionScriptRelativePath:: -3}"
    strFunctionNamespace="${strFunctionNamespace//_/.}"
    strFunctionNamespace="${strFunctionNamespace//\//.}"
    
    str_FUNCTION_TO_MANUAL+="SHELLNS_MAIN_MAPP_FUNCTION_TO_MANUAL[\"${strFunctionName}\"]=\"\${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/${strManualRelativePath}\"\n"
    str_NAMESPACE_TO_FUNCTION+="SHELLNS_MAIN_MAPP_NAMESPACE_TO_FUNCTION[\"${strFunctionNamespace}\"]=\"${strFunctionName}\"\n"
  done

  local strFileContent=""
  strFileContent+="#!/usr/bin/env bash\n"
  strFileContent+="\n"
  strFileContent+="#\n"
  strFileContent+="# Get path to the manuals directory.\n"
  strFileContent+="SHELLNS_TMP_PATH_TO_DIR_MANUALS=\"\$(tmpPath=\$(dirname \"\${BASH_SOURCE[0]}\"); realpath \"\${tmpPath}/src-manuals/\${SHELLNS_MAIN_INTERFACE_LOCALE}\")\"\n" 
  strFileContent+="\n"
  strFileContent+="\n"
  strFileContent+="#\n"
  strFileContent+="# Mapp function to manual.\n"
  strFileContent+="${str_FUNCTION_TO_MANUAL}"
  strFileContent+="\n"
  strFileContent+="\n"
  strFileContent+="#\n"
  strFileContent+="# Mapp namespace to function.\n"
  strFileContent+="${str_NAMESPACE_TO_FUNCTION}"
  strFileContent+="\n"
  strFileContent+="\n"
  strFileContent+="\n"
  strFileContent+="\n"
  strFileContent+="\n"
  strFileContent+="unset SHELLNS_TMP_PATH_TO_DIR_MANUALS"

  local strTgtFilePath="${SHELLNS_TMP_PACKAGE_DIR_PATH}/ns.sh"

  echo -ne "${strFileContent}" > "${strTgtFilePath}"
}

