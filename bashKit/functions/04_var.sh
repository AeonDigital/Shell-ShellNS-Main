#!/usr/bin/env bash

#
# Dumps a variable value after checking if it is empty or invalid.
#
# @param string $1
# Variable name.
#
# @return string
varDump() {
  local varName="${1}"
  local varValue="${!varName}"
  local -A assocMetaData
  assocMetaData["type"]="string"
  assocMetaData["readonly"]="0"
  assocMetaData["exported"]="1"

  local printDump="1"
  if [ "${3}" == "0" ]; then
    printDump="0"
  fi



  # Get declare info
  local rawDeclareInfo=""
  rawDeclareInfo=$(declare -p "${varName}" 2>/dev/null)

  local declareStatus=""
  declareStatus=$(stringTrim "${rawDeclareInfo#declare -}")
  declareStatus=$(stringTrim "${declareStatus%% *}")


  if ! declare -p "${varName}" &>/dev/null; then
    assocMetaData["unset"]="1"
  else
    if [[ "${declareStatus}" =~ "r" ]]; then
      assocMetaData["readonly"]="1"
    fi
    
    if [[ "${declareStatus}" =~ "x" ]]; then
      assocMetaData["exported"]="1"
    fi

    if [[ "${declareStatus}" =~ "a" ]] || [[ "${declareStatus}" =~ "A" ]]; then
      if [[ "${declareStatus}" =~ "a" ]]; then
        assocMetaData["type"]="array"
      fi
      if [[ "${declareStatus}" =~ "A" ]]; then
        assocMetaData["type"]="assoc"
      fi
    else
      if [[ "${declareStatus}" =~ "i" ]]; then
        assocMetaData["type"]="integer"
      fi
    fi
  fi



  if [ "${2}" != "" ]; then
    local -n tmpRefVarDump_ExportAssoc="${2}"
    if ! varAssocClear "${2}" ]; then
      return "1"
    fi
    
    local it=""
    for it in "${!assocMetaData[@]}"; do
      tmpRefVarDump_ExportAssoc["${it}"]="${assocMetaData[${it}]}"
    done
  fi



  if [ "${printDump}" == "1" ]; then
    echo "# Dump variable"
    echo "## Variable '${varName}':"

    # Check if variable exists
    if [ "${assocMetaData["unset"]}" == "1" ]; then
      echo "   - unset"
    else
      # Check readonly
      if [ "${assocMetaData["readonly"]}" == "1" ]; then
        echo "   - readonly"
      fi

      # Check exported
      if [ "${assocMetaData["exported"]}" == "1" ]; then
        echo "   - exported"
      fi

      echo "   - ${assocMetaData["type"]}"
      echo ""
      if [ "${assocMetaData["type"]}" == "array" ] || [ "${assocMetaData["type"]}" == "assoc" ]; then
        echo "## ${assocMetaData["type"]^} values"

        local -n tmpRefVarDump_ArrayAssocPrintValues="${varName}"
        local k=""
        local v=""
        local sortedKeys=($(for it in "${!tmpRefVarDump_ArrayAssocPrintValues[@]}"; do echo "${it}"; done | sort))
        for k in "${sortedKeys[@]}"; do
          v="${tmpRefVarDump_ArrayAssocPrintValues[${k}]}"
          echo "   [${k}]='${v}'"
        done
      else
        if [ "${assocMetaData["type"]}" == "integer" ]; then
          echo "## Value : ${varValue}"
        else
          echo "## Value : '${varValue}'"
        fi
      fi
    fi
  fi
}





#
# Example of usage:
#
# ``` shell 
# declre -a arr
# if varIsArray "arr"; then
#   echo "Is array"
# fi
#
# if ! varIsArray "bar"; then
#   echo "Not a array"
# fi
# ```



#
# Checks if an array exists.
#
# @param string $1
# Name of the array.
#
# return status
varIsArray() {
  local arrayName="${1}"
  
  if [ "${arrayName}" == "" ] || ! [[ "$(declare -p "${arrayName}" 2> /dev/null)" == "declare -a"* ]]; then
    return "1"
  fi

  return "0"
}
#
# Checks if an assoc exists.
#
# @param string $1
# Name of the associative array.
#
# return status
varIsAssoc() {
  local assocName="${1}"
  
  if [ "${assocName}" == "" ] || ! [[ "$(declare -p "${assocName}" 2> /dev/null)" == "declare -A"* ]]; then
    return "1"
  fi

  return "0"
}
#
# Check if the given array/assoc exists and is empty.
#
# @param string $1
# Name of the array/assoc.
#
# return status
# - 0 : array/assoc is empty
# - 1 : array/assoc not exists or is not empty
varIsArrayExistsAndIsEmpty() {
  local arrName="${1}"

  #
  # check if array exists
  if ! varIsArray "${arrName}" && ! varIsAssoc "${arrName}"; then
    return "1"
  fi

  #
  # check if array is not empty
  local -n arr="${arrName}"
  if [ "${#arr[@]}" -gt "0" ]; then
    return "1"
  fi
  
  return "0"
}
#
# Check if the given array/assoc exists and not is empty.
#
# Wrapper for 'varIsArrayExistsAndIsEmpty'.
#
# @param string $1
# Name of the array/assoc.
#
# return status
# - 0 : array/assoc is not empty
# - 1 : array/assoc not exists or is empty
varArrayExistsAndHasNoItens() {
  varIsArrayExistsAndIsEmpty "${1}"; return "$?"
}
#
# Check if the given array/assoc exists and not is empty.
#
# @param string $1
# Name of the array/assoc.
#
# return status
# - 0 : array/assoc is not empty
# - 1 : array/assoc not exists or is empty
varIsArrayExistsAndIsNotEmpty() {
  local arrName="${1}"

  #
  # check if array exists
  if ! varIsArray "${arrName}" && ! varIsAssoc "${arrName}"; then
    return "1"
  fi

  #
  # check if array is not empty
  local -n arr="${arrName}"
  if [ "${#arr[@]}" -eq "0" ]; then
    return "1"
  fi
  
  return "0"
}
#
# Check if the given array/assoc exists and not is empty.
#
# Wrapper for 'varIsArrayExistsAndIsNotEmpty'.
#
# @param string $1
# Name of the array/assoc.
#
# return status
# - 0 : array/assoc is not empty
# - 1 : array/assoc not exists or is empty
varArrayExistsAndHasItens() {
  varIsArrayExistsAndIsNotEmpty "${1}"; return "$?"
}




#
# Completely clears the indicated array.
#
# @param string $1
# Name of array.
#
# @return status+string
varArrayClear() {
  if ! varIsArray "${1}" ]; then
    messageError "return array '${1}' not exists or is not an array!"
    return "1"
  fi

  local -n tmpArrayClear="${1}"
  tmpArrayClear=()

  return "0"
}
#
# Completely clears the indicated associative array.
#
# @param string $1
# Name of assoc array.
#
# @return status+string
varAssocClear() {
  if ! varIsAssoc "${1}" ]; then
    messageError "return assoc '${1}' not exists or is not an assoc array!"
    return "1"
  fi

  local -n tmpAssocClear="${1}"
  local it=""
  for it in "${!tmpAssocClear[@]}"; do
    unset tmpAssocClear["${it}"]
  done

  return "0"
}




#
# Checks if a function exists.
#
# @param string $1
# Name of the function.
#
# return status
functionExists() {
  local functionName="${1}"

  if [ "${functionName}" == "" ] || ! declare -F "${functionName}" &>/dev/null; then
    return "1"
  fi

  return "0"
}





#
# Checks if a given value is a valid boolean (1 or 0).
#
# @param string $1
# Value to be checked.
#
# return status
varIsBool() {
  local boolValue="${1}"

  if [ "${boolValue}" != "0" ] && [ "${boolValue}" != "1" ]; then
    return "1"
  fi

  return "0"
}



#
# Checks if a given value is a valid integer.
#
# @param string $1
# Value to be checked.
#
# return status
varIsInt() {
  local intValue="${1}"

  if ! [[ "${intValue}" =~ ^-?[0-9]+$ ]]; then
    return "1"
  fi

  return "0"
}



#
# Checks if a given value is a valid float.
#
# @param string $1
# Value to be checked.
#
# return status
varIsFloat() {
  local floatValue="${1}"

  if ! [[ "${floatValue}" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
    return "1"
  fi

  return "0"
}