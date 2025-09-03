#!/usr/bin/env bash

#
# Get meta information about a property of an object type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the property.
#
# @param string $3
# Name of the return assoc.
# The target array will contain:
# - [type]    => type of the property
# - [name]    => name of the property
# - [default] => default value of the property
#
# return status+array
objectMetaProperty() {
  local typeObject="${1}"
  
  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  local propertyName="${2}"
  if ! objectCheckTypePropertyExists "${typeObject}" "${propertyName}"; then
    messageError "Property is not defined for object type | '${typeObject}.${propertyName}'"
    return "1"
  fi

  if ! varIsAssoc "${3}"; then
    messageError "Return assoc not exists or is not an assoc array | '${3}'"
    return "1"
  fi

  local registeredName="${typeObject}_${propertyName}"

  local -n tmpMetaPropArray="${3}"
  tmpMetaPropArray["name"]="${propertyName}"
  tmpMetaPropArray["type"]="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${registeredName}_type"]}"
  tmpMetaPropArray["default"]="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${registeredName}_default"]}"

  return "0"
}





#
# Get meta information about all properties of an object type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the return array for property types.
# The target array will contain:
# - [0] => type of the property 1
# - [1] => type of the property 2
# - [2] => type of the property 3
# - ... 
#
# @param string $3
# Name of the return array for property names.
# The target array will contain:
# - [0] => name of the property 1
# - [1] => name of the property 2
# - [2] => name of the property 3
# - ...
#
# @param string $4
# Name of the return array for property default values.
# The target array will contain:
# - [0] => default value of the property 1
# - [1] => default value of the property 2
# - [2] => default value of the property 3
# - ...
#
# @param string $5
# (optional) Name of the return variable for max length of property types.
#
# @param string $6
# (optional) Name of the return variable for max length of property names.
#
# @return status+string
objectMetaTypeGetProperties() {
  local typeObject="${1}"
  
  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! varIsArray "${2}"; then
    messageError "Return array not exists or is not an array | '${2}'"
    return "1"
  fi
  local -n arrPropTypes="${2}"
  arrPropTypes=()

  if ! varIsArray "${3}"; then
    messageError "Return array not exists or is not an array | '${3}'"
    return "1"
  fi
  local -n arrPropNames="${3}"
  arrPropNames=()

  if ! varIsArray "${4}"; then
    messageError "Return array not exists or is not an array | '${4}'"
    return "1"
  fi
  local -n arrPropDefault="${4}"
  arrPropDefault=()


  local intMaxLengthPropType="0"
  local intMaxLengthPropName="0"
  if [ "${5}" != "" ] && [ "${6}" != "" ]; then
    local -n intMaxLengthPropType="${5}"
    local -n intMaxLengthPropName="${6}"
  fi


  local objPropertiesNames="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES[${typeObject}]}"
  if [ "${objPropertiesNames}" == "" ]; then
    messageError "The given object type has no properties defined | '${typeObject}'"
    return "1"
  fi

  local -a arrPropertiesNames=()
  IFS=';' read -r -a arrPropertiesNames <<< "${objPropertiesNames}"
  unset IFS



  local propertyType=""
  local propertyName=""
  local propertyDefault=""
  local -A assocPropertyMeta

  for propertyName in "${arrPropertiesNames[@]}"; do
    objectMetaProperty "${typeObject}" "${propertyName}" "assocPropertyMeta"; statusSet "$?"
    if [ $(statusGet) == "0" ]; then
      propertyType="${assocPropertyMeta[type]}"
      propertyName="${assocPropertyMeta[name]}"
      propertyDefault="${assocPropertyMeta[default]}"

      arrPropTypes+=("${propertyType}")
      arrPropNames+=("${propertyName}")
      arrPropDefault+=("${propertyDefault}")

      if [ "${#propertyType}" -gt "${intMaxLengthPropType}" ]; then
        intMaxLengthPropType="${#propertyType}"
      fi
      if [ "${#propertyName}" -gt "${intMaxLengthPropName}" ]; then
        intMaxLengthPropName="${#propertyName}"
      fi
    fi
  done

  return "0"
}