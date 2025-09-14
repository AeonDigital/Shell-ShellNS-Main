#!/usr/bin/env bash

#
# Define a new type of object.
# The object will be in 'definitionMode' until 'objectNewTypeEnd' is called.
#
# @param string $1
# Type of the object.
#
# @param function $2
# [optional] Constructor.
# Will run after each initializated instance.
#
# return status+string
objectTypeCreate() {
  local typeObject="${1}"
  local typeConstructor="${2}"

  if [ "${typeObject}" == "" ]; then
    messageError "Invalid object type!"
    return "1"
  fi

  if objectCheckTypeExists "${typeObject}"; then
    messageError "Object type '${typeObject}' is already defined!"
    return "1"
  fi

  if [[ ! "${typeObject}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    messageError "Invalid object type name | '${typeObject}'"
    return "1"
  fi

  if [ "${typeConstructor}" != "" ] && ! varIsFunction "${typeConstructor}" ]; then
    messageError "Invalid constructor | '${typeConstructor}'; expected function."
  fi


  SHELLNS_MAIN_OBJECT_TYPES["${typeObject}"]="-"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${typeObject}"]=""
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}"]=""
  SHELLNS_MAIN_OBJECT_TYPE_CONSTRUCTORS["${typeObject}"]="${typeConstructor}"

  objectTypeCreateStart "${typeObject}"

  eval "${typeObject}() { objectInstanceAccess \"${typeObject}\" \"\$@\"; }"
}


#
# Starts the object creation period.
#
# @param string $1
# Type of the object.
#
# return status+string
objectTypeCreateStart() {
  local typeObject="${1}"

  if ! objectCheckTypeExists "${typeObject}"; then
    return "1"
  fi

  SHELLNS_MAIN_OBJECT_TYPES["${typeObject}"]="definitionMode"
}


#
# Ends the object creation period.
#
# @param string $1
# Type of the object.
#
# return status+string
objectTypeCreateEnd() {
  local typeObject="${1}"

  if ! objectCheckTypeExists "${typeObject}"; then
    return "1"
  fi

  SHELLNS_MAIN_OBJECT_TYPES["${typeObject}"]="-"
}





#
# Define a new property for an object type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Type of the property. 
# Possible values are: int, float, bool, string.
#
# @param string $3
# Name of the property.
#
# @param mixed $4
# Default value of the property.
#
# @param mixed $5
# [optional]
# If defined must be a function used to validate new values to be set.
#
# @param mixed $6
# [optional]
# If defined must be a function used to get the current value.
#
# return status
objectTypeSetProperty() {
  local typeObject="${1}"
  local typePropType="${2}"
  local typePropName="${3}"
  local typePropDefault="${4}"
  local typePropSetFn="${5}"
  local typePropGetFn="${6}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi
  if ! objectCheckTypeInDefinitionMode "${typeObject}"; then
    messageError "Object type is not in definition mode | '${typeObject}'"
    return "1"
  fi

  if [[ ! " ${SHELLNS_MAIN_OBJECT_ALLOWED_PROPERTIES_TYPES[*]} " =~ " ${typePropType} " ]]; then
    messageError "Invalid property type | '${typePropType}'"
    return "1"
  fi

  if [ "${typePropName}" == "" ] || [[ ! "${typePropName}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    messageError "Invalid property name | '${typePropName}'"
    return "1"
  fi
  if objectCheckTypePropertyExists "${typeObject}" "${typePropName}"; then
    messageError "Property already exists for the object | '${typeObject}.${typePropName}'"
    return "1"
  fi
  
  if [ "${typePropDefault}" != "" ]; then
    if [ "${typePropType}" == "array" ] || [ "${typePropType}" == "assoc" ]; then 
      messageError "Invalid given default value | '${typeObject}.${typePropName}=${typePropDefault}'; Type '"${typePropType}"' not accepts default value."
      return "1"
    fi
    if ! objectCheckPropertyValue "${typePropType}" "${typePropDefault}"; then
      messageError "Invalid given default value | '${typeObject}.${typePropName}=${typePropDefault}'; expected a valid '${typeObject}'"
      return "1"
    fi
  fi

  if [ "${typePropSetFn}" != "" ] && ! varIsFunction "${typePropSetFn}"; then
    messageError "Invalid set method (not a function) | '${typePropSetFn}'"
    return "1"
  fi
  if [ "${typePropGetFn}" != "" ] && ! varIsFunction "${typePropGetFn}"; then
    messageError "Invalid get method (not a function) | '${typePropGetFn}'"
    return "1"
  fi


  local propertyRegName="${typeObject}_${typePropName}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}"]+="${typePropName};"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${propertyRegName}"]="-"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${propertyRegName}_type"]="${typePropType}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${propertyRegName}_name"]="${typePropName}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${propertyRegName}_default"]="${typePropDefault}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${propertyRegName}_set"]="${typePropSetFn}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${propertyRegName}_get"]="${typePropGetFn}"

  return "0"
}





#
# Define a new method for an object type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the method.
#
# @param string $3
# Name of the real function called.
#
# return status
objectTypeSetMethod() {
  local typeObject="${1}"
  local typeMethodName="${2}"
  local typeMethodFunction="${3}"


  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! objectCheckTypeInDefinitionMode "${typeObject}"; then
    messageError "Object type is not in definition mode | '${typeObject}'"
    return "1"
  fi

  if [ "${typeMethodName}" == "" ] || [[ ! "${typeMethodName}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    messageError "Invalid method name | '${typeMethodName}'"
    return "1"
  fi
  if objectCheckTypeMethodExists "${typeObject}" "${typeMethodName}"; then
    messageError "Method already exists for the object | '${typeObject}.${typeMethodName}()'"
    return "1"
  fi

  if ! varIsFunction "${typeMethodFunction}"; then
    messageError "Invalid function | '${typeMethodFunction}'"
    return "1"
  fi
  
  local regTypeMethodName="${typeObject}_${typeMethodName}"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${typeObject}"]+="${typeMethodName};"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${typeObject}_functions"]+="${typeMethodFunction};"

  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${regTypeMethodName}"]="-"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${regTypeMethodName}_name"]="${typeMethodName}"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${regTypeMethodName}_function"]="${typeMethodFunction}"

  return "0"
}





#
# Dump the definition of an object type.
#
# @param string $1
# Type of the object.
#
# return status+string 
objectTypeDump() {
  local typeObject="${1}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  local objDefMode=$(objectCheckTypeInDefinitionMode "${typeObject}" && echo "true" || echo "false")

  local -a dumpArrTypePropTypes=()
  local -a dumpArrTypePropNames=()
  local -a dumpArrTypePropDefault=()

  local dumpIntMaxLengthPropType="0"
  local dumpIntMaxLengthPropName="0"

  objectMetaTypeGetProperties "${typeObject}" "dumpArrTypePropTypes" "dumpArrTypePropNames" "dumpArrTypePropDefault" "dumpIntMaxLengthPropType" "dumpIntMaxLengthPropName"
  ((dumpIntMaxLengthPropType = dumpIntMaxLengthPropType + 2))


  local -a dumpArrTypeMethodNames=()
  local -a dumpArrTypeMethodFunctions=()
  objectMetaTypeGetMethods "${typeObject}" "dumpArrTypeMethodNames" "dumpArrTypeMethodFunctions"



  echo "# Dump object type"
  echo "## Type '${typeObject}'"
  echo "   - Def mode : ${objDefMode}"
  echo ""

  if [ "${#dumpArrTypePropTypes[@]}" -gt "0" ]; then
    echo "## Properties :"

    local it="" 
    local propertyType=""
    local propertyName=""
    local propertyDefault=""

    for it in "${!dumpArrTypePropTypes[@]}"; do
      propertyType=$(stringPaddingL "[${dumpArrTypePropTypes[${it}]}]" " " "${dumpIntMaxLengthPropType}")
      propertyName=$(stringPaddingR "${dumpArrTypePropNames[${it}]}" " " "${dumpIntMaxLengthPropName}")
      propertyDefault="${dumpArrTypePropDefault[${it}]}"

      echo "   ${propertyType} ${propertyName} = '${propertyDefault}'"
    done
  fi


  if [ "${#dumpArrTypeMethodNames[@]}" -gt "0" ]; then
    echo ""
    echo "## Methods :"

    local it="" 
    local typeMethodName=""
    local typeMethodFunction=""

    for it in "${!dumpArrTypeMethodNames[@]}"; do
      typeMethodName="${dumpArrTypeMethodNames[${it}]}"
      typeMethodFunction="${dumpArrTypeMethodFunctions[${it}]}"

      echo "   - ${typeMethodName} -> ${typeMethodFunction}()"
    done
  fi

  return "0"
}