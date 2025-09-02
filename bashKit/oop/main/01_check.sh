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
  local typePropName="${2}"
  local regTypePropName="${typeObject}_${typePropName}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES[${regTypePropName}]}" == "-" ]; then
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
  local typeMethodName="${2}"
  local regTypeMethodName="${typeObject}_${typeMethodName}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPE_METHODS[${regTypeMethodName}]}" == "-" ]; then
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
    case "${propertyType}" in
      "bool")
        if ! varIsBool "${propertyValue}"; then
          return "1"
        fi
        ;;

      "int")
        if ! varIsInt "${propertyValue}"; then
          return "1"
        fi
        ;;

      "float")
        if ! varIsFloat "${propertyValue}"; then
          return "1"
        fi
        ;;

      "array")
        if ! varIsArray "${propertyValue}"; then
          return "1"
        fi
        ;;

      "assoc")
        if ! varIsAssoc "${propertyValue}"; then
          return "1"
        fi
        ;;
    esac 
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
  local typeInstanceName="${2}"

  if [ "${SHELLNS_MAIN_OBJECT_TYPES[${typeObject}]}" == "" ]; then
    return "1"
  fi

  local regTypeInstanceName="${typeObject}_${typeInstanceName}"
  if [ "${SHELLNS_MAIN_OBJECT_INSTANCES[${regTypeInstanceName}]}" == "" ]; then
    return "1"
  fi

  return "0"
}
