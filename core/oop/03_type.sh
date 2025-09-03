#!/usr/bin/env bash

#
# Define a new type of object.
# The object will be in 'definitionMode' until 'objectNewTypeEnd' is called.
#
# @param string $1
# Type of the object.
#
# return status+string
objectTypeCreate() {
  local typeObject="${1}"

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


  SHELLNS_MAIN_OBJECT_TYPES["${typeObject}"]="-"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${typeObject}"]=""
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}"]=""

  objectTypeCreateStart "${typeObject}"
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
# return status
objectTypeSetProperty() {
  local typeObject="${1}"
  local propertyType="${2}"
  local propertyName="${3}"
  local propertyDefault="${4}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi
  if ! objectCheckTypeInDefinitionMode "${typeObject}"; then
    messageError "Object type is not in definition mode | '${typeObject}'"
    return "1"
  fi

  if [[ ! " ${SHELLNS_MAIN_OBJECT_ALLOWED_PROPERTIES_TYPES[*]} " =~ " ${propertyType} " ]]; then
    messageError "Invalid property type | '${propertyType}'"
    return "1"
  fi

  if [ "${propertyName}" == "" ] || [[ ! "${propertyName}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    messageError "Invalid property name | '${propertyName}'"
    return "1"
  fi
  if objectCheckTypePropertyExists "${typeObject}" "${propertyName}"; then
    messageError "Property already exists for the object | '${typeObject}.${propertyName}'"
    return "1"
  fi
  
  if [ "${propertyDefault}" != "" ]; then
    if ! objectCheckPropertyValue "${propertyType}" "${propertyDefault}"; then
      messageError "Invalid given default value | '${typeObject}.${propertyName}=${propertyDefault}'; expected a valid '${typeObject}'"
      return "1"
    fi
  fi

  local registeredName="${typeObject}_${propertyName}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}"]+="${propertyName};"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${registeredName}"]="-"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${registeredName}_type"]="${propertyType}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${registeredName}_name"]="${propertyName}"
  SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${registeredName}_default"]="${propertyDefault}"

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
# return status
objectTypeSetMethod() {
  local typeObject="${1}"
  local methodName="${2}"


  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! objectCheckTypeInDefinitionMode "${typeObject}"; then
    messageError "Object type is not in definition mode | '${typeObject}'"
    return "1"
  fi

  if [ "${methodName}" == "" ] || [[ ! "${methodName}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    messageError "Invalid method name | '${methodName}'"
    return "1"
  fi
  if objectCheckTypeMethodExists "${typeObject}" "${methodName}"; then
    messageError "Method already exists for the object | '${typeObject}.${methodName}()'"
    return "1"
  fi
  
  local registeredName="${typeObject}_${methodName}"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${typeObject}"]+="${methodName};"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${registeredName}"]="-"
  SHELLNS_MAIN_OBJECT_TYPE_METHODS["${registeredName}_name"]="${methodName}"

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
  local -a arrPropertiesNames=()
  IFS=';' read -r -a arrPropertiesNames <<< "${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES[${typeObject}]}"
  local -a arrMethodsNames=()
  IFS=';' read -r -a arrMethodsNames <<< "${SHELLNS_MAIN_OBJECT_TYPE_METHODS[${typeObject}]}"
  unset IFS



  local -a arrPropertyTypes=()
  local -a arrPropertyNames=()
  local -a arrPropertyDefault=()

  local intMaxLengthPropertyType="0"
  local intMaxLengthPropertyName="0"

  objectMetaTypeGetProperties "${typeObject}" "arrPropertyTypes" "arrPropertyNames" "arrPropertyDefault" "intMaxLengthPropertyType" "intMaxLengthPropertyName"
  ((intMaxLengthPropertyType = intMaxLengthPropertyType + 2))



  echo "# Dump object type"
  echo "## Type '${typeObject}'"
  echo "   - Def mode : ${objDefMode}"
  echo ""

  if [ "${#arrPropertyTypes[@]}" -gt "0" ]; then
    echo "## Properties :"

    local it="" 
    local propertyType=""
    local propertyName=""
    local propertyDefault=""

    for it in "${!arrPropertyTypes[@]}"; do
      propertyType=$(stringPaddingL "[${arrPropertyTypes[${it}]}]" " " "${intMaxLengthPropertyType}")
      propertyName=$(stringPaddingR "${arrPropertyNames[${it}]}" " " "${intMaxLengthPropertyName}")
      propertyDefault="${arrPropertyDefault[${it}]}"

      echo "   ${propertyType} ${propertyName} = '${propertyDefault}'"
    done
  fi


  if [ "${#arrMethods[@]}" -gt "0" ]; then
    echo ""
    echo "## Methods :"
    local methodName=""
    for methodName in "${arrMethods[@]}"; do
      if [ "${methodName}" != "" ]; then
        echo "   - ${methodName}()"
      fi
    done
  fi

  return "0"
}
