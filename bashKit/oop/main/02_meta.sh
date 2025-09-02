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

  local typePropName="${2}"
  if ! objectCheckTypePropertyExists "${typeObject}" "${typePropName}"; then
    messageError "Property is not defined for object type | '${typeObject}.${typePropName}'"
    return "1"
  fi

  if ! varIsAssoc "${3}"; then
    messageError "Return assoc not exists or is not an assoc array | '${3}'"
    return "1"
  fi

  local regTypePropName="${typeObject}_${typePropName}"

  local -n tmpMetaPropArray="${3}"
  tmpMetaPropArray["name"]="${typePropName}"
  tmpMetaPropArray["type"]="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${regTypePropName}_type"]}"
  tmpMetaPropArray["default"]="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${regTypePropName}_default"]}"

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
  local -n metaArrTypePropTypes="${2}"
  metaArrTypePropTypes=()

  if ! varIsArray "${3}"; then
    messageError "Return array not exists or is not an array | '${3}'"
    return "1"
  fi
  local -n metaArrTypePropNames="${3}"
  metaArrTypePropNames=()

  if ! varIsArray "${4}"; then
    messageError "Return array not exists or is not an array | '${4}'"
    return "1"
  fi
  local -n metaArrTypePropDefault="${4}"
  metaArrTypePropDefault=()


  local metaIntMaxLengthPropType="0"
  local metaIntMaxLengthPropName="0"
  if [ "${5}" != "" ] && [ "${6}" != "" ]; then
    local -n metaIntMaxLengthPropType="${5}"
    local -n metaIntMaxLengthPropName="${6}"
  fi


  local metaObjPropertiesNames="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES[${typeObject}]}"
  if [ "${metaObjPropertiesNames}" == "" ]; then
    return "0"
  fi

  local -a metaArrPropertiesNames=()
  IFS=';' read -r -a metaArrPropertiesNames <<< "${metaObjPropertiesNames}"



  local typePropType=""
  local typePropName=""
  local typePropDefault=""
  local -A assocPropertyMeta

  for typePropName in "${metaArrPropertiesNames[@]}"; do
    objectMetaProperty "${typeObject}" "${typePropName}" "assocPropertyMeta"; statusSet "$?"
    if [ $(statusGet) == "0" ]; then
      typePropType="${assocPropertyMeta[type]}"
      typePropName="${assocPropertyMeta[name]}"
      typePropDefault="${assocPropertyMeta[default]}"

      metaArrTypePropTypes+=("${typePropType}")
      metaArrTypePropNames+=("${typePropName}")
      metaArrTypePropDefault+=("${typePropDefault}")

      if [ "${#typePropType}" -gt "${metaIntMaxLengthPropType}" ]; then
        metaIntMaxLengthPropType="${#typePropType}"
      fi
      if [ "${#typePropName}" -gt "${metaIntMaxLengthPropName}" ]; then
        metaIntMaxLengthPropName="${#typePropName}"
      fi
    fi
  done

  return "0"
}





#
# Get meta information about all methods of an object type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the return array for method names.
# The target array will contain:
# - [0] => method 1
# - [1] => method 2
# - [2] => method 3
# - ... 
#
# @param string $3
# Name of the return array for method function real names.
# The target array will contain:
# - [0] => function 1
# - [1] => function 2
# - [2] => function 3
# - ... 
#
# @return status+string
objectMetaTypeGetMethods() {
  local typeObject="${1}"
  
  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! varIsArray "${2}"; then
    messageError "Return array not exists or is not an array | '${2}'"
    return "1"
  fi
  local -n metaArrTypeMethodNames="${2}"
  metaArrTypeMethodNames=()

  if ! varIsArray "${3}"; then
    messageError "Return array not exists or is not an array | '${3}'"
    return "1"
  fi
  local -n metaArrTypeMethodFunctions="${3}"
  metaArrTypeMethodFunctions=()


  local objMethodNames="${SHELLNS_MAIN_OBJECT_TYPE_METHODS[${typeObject}]}"
  if [ "${objMethodNames}" == "" ]; then
    messageError "The given object type has no methods defined | '${typeObject}'"
    return "0"
  fi
  IFS=';' read -r -a metaArrTypeMethodNames <<< "${objMethodNames}"


  local objMethodFunctions="${SHELLNS_MAIN_OBJECT_TYPE_METHODS[${typeObject}_functions]}"
  IFS=';' read -r -a metaArrTypeMethodFunctions <<< "${objMethodFunctions}"

  return "0"
}





#
# Retrieve the given objects with the property name of the object type and
# its current values.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the instance.
#
# @param string $3
# Name of the return array for property names.
# The target array will contain:
# - [0] => property name 1
# - [1] => property name 2
# - [2] => property name 3
# - ... 
#
# @param string $4
# Name of the return array with the property values.
# The target array will contain:
# - [0] => property value 1
# - [1] => property value 2
# - [2] => property value 3
# - ... 
#
# @return status+string
objectMetaInstanceProperties() {
  local typeObject="${1}"
  local typeInstanceName="${2}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! objectCheckInstanceExists "${typeObject}" "${typeInstanceName}"; then
    messageError "Object type instance is not defined | '${typeObject}.${typeInstanceName}'"
    return "1"
  fi

  if ! varIsArray "${3}"; then
    messageError "Return array not exists or is not an array | '${3}'"
    return "1"
  fi
  local -n metaArrInstancePropNames="${3}"
  metaArrInstancePropNames=()

  if ! varIsArray "${4}"; then
    messageError "Return array not exists or is not an array | '${4}'"
    return "1"
  fi
  local -n metaArrInstancePropValues="${4}"
  metaArrInstancePropValues=()



  local metaObjPropertiesNames="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES[${typeObject}]}"
  if [ "${metaObjPropertiesNames}" == "" ]; then
    return "0"
  fi
  IFS=';' read -r -a metaArrInstancePropNames <<< "${metaObjPropertiesNames}"

  local typePropName=""
  for typePropName in "${metaArrInstancePropNames[@]}"; do
    metaArrInstancePropValues+=("${SHELLNS_MAIN_OBJECT_INSTANCES_VALUES[${typeObject}_${typeInstanceName}_${typePropName}]}")
  done

  return "0"
}

