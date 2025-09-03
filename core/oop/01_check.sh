#!/usr/bin/env bash

#
# Check if a given object type exists.
#
# @param string $1
# Type of the object.
#
# return status
objectCheckTypeExists() {
  local typeObject="${1}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPES[${typeObject}]}" == "" ]; then
    return "1"
  fi

  return "0"
}



#
# Check if a given object type is in definition mode.
#
# @param string $1
# Type of the object.
#
# return status
objectCheckTypeInDefinitionMode() {
  local typeObject="${1}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPES[${typeObject}]}" == "definitionMode" ]; then
    return "0"
  fi

  return "1"
}



#
# Check if a property exists for an object type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the property.
#
# return status
objectCheckTypePropertyExists() {
  local typeObject="${1}"
  local propertyName="${2}"
  local registeredName="${typeObject}_${propertyName}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES[${registeredName}]}" == "-" ]; then
    return "0"
  fi

  return "1"
}



#
# Check if a method exists for an object type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the method.
#
# return status
objectCheckTypeMethodExists() {
  local typeObject="${1}"
  local methodName="${2}"
  local registeredName="${typeObject}_${methodName}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPE_METHODS[${registeredName}]}" == "-" ]; then
    return "0"
  fi

  return "1"
}



#
# Check if a value is valid for a property type.
#
# @param string $1
# Type of the property.
#
# @param mixed $2
# Value to check.
#
# return status
objectCheckPropertyValue() {
  local propertyType="${1}"
  local propertyValue="${2}"

  if [ "${propertyValue}" != "" ]; then
    if [[ "${propertyType}" == "int" ]]; then
      if ! [[ "${propertyValue}" =~ ^-?[0-9]+$ ]]; then
        return "1"
      fi
    elif [[ "${propertyType}" == "float" ]]; then
      if ! [[ "${propertyValue}" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
        return "1"
      fi
    elif [[ "${propertyType}" == "bool" ]]; then
      if [[ "${propertyValue}" != "1" && "${propertyValue}" != "0" ]]; then
        return "1"
      fi
    fi
  fi

  return "0"
}





#
# Check if a given instance of type exists.
#
# @param string $1
# Type of the object.
#
# @param string $1
# Name of the instance.
#
# return status
objectCheckInstanceExists() {
  local typeObject="${1}"
  local instanceName="${2}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPES[${typeObject}]}" == "" ]; then
    return "1"
  fi

  local registerName="${typeObject}_${instanceName}"
  if [ "${SHELLNS_MAIN_OBJECT_INSTANCES[${registerName}]}" == "" ]; then
    return "1"
  fi

  return "0"
}
