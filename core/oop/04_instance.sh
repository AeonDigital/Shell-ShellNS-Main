#!/usr/bin/env bash

#
# TODO -> Seguir deste ponto, criando a instância nova
# https://gist.github.com/leandronsp/5e7c94ee5b4ea53ed28e9824ca8e243e

#
# Define a new instance of a type.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the instance.
#
# return status+string
objectInstanceNew() {
  local typeObject="${1}"
  local typeInstanceName="${2}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if [ "${typeInstanceName}" == "" ] ||  [[ ! "${typeInstanceName}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    messageError "Invalid instance name | '${typeInstanceName}'"
    return "1"
  fi

  if objectCheckInstanceExists "${typeObject}" "${typeInstanceName}"; then
    messageError "Instance alread exists | '${typeObject}.${typeInstanceName}'"
    return "1"
  fi

  local regTypeInstanceName="${typeObject}_${typeInstanceName}"
  SHELLNS_MAIN_OBJECT_INSTANCES["${typeObject}"]+="${typeInstanceName};"
  SHELLNS_MAIN_OBJECT_INSTANCES["${regTypeInstanceName}"]="-"



  local -a arrTypePropTypes=()
  local -a arrTypePropNames=()
  local -a arrTypePropDefault=()

  local intMaxLengthPropType="0"
  local intMaxLengthPropName="0"

  objectMetaTypeGetProperties "${typeObject}" "arrTypePropTypes" "arrTypePropNames" "arrTypePropDefault" "intMaxLengthPropType" "intMaxLengthPropName"
  
  local it=""
  local typePropName=""
  local typePropDefault=""
  local regTypeInstancePropName=""
  for it in "${!arrTypePropNames[@]}"; do
    typePropName="${arrTypePropNames[${it}]}"
    typePropDefault="${arrTypePropDefault[${it}]}"

    regTypeInstancePropName="${regTypeInstanceName}_${typePropName}"
    SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstancePropName}"]="${typePropDefault}"
  done



  local -a arrTypeMethodNames=()
  objectMetaTypeGetMethods "${typeObject}" "arrTypeMethodNames"

  local it=""
  local typeMethodName=""
  local regTypeInstanceMethodName=""
  for it in "${!arrTypeMethodNames[@]}"; do
    typeMethodName="${arrTypeMethodNames[${it}]}"

    regTypeInstanceMethodName="${regTypeInstanceName}_${typeMethodName}"
    SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMethodName}"]="${typeMethodName}"
  done


  return "0"
}





#
# Method defined for all object type.
# That´s the entrypoint of each call for an existent object.
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the instance.
#
# @param string $3
# Action.
# Possible values are: get set exec.
#
# @param string $4
# Property or Method name.
#
# return status+string
objectInstanceAccess() {
  local typeObject="${1}"
  local typeInstanceName="${2}"
  local typeInstanceAction="${3,,}"
  local typeInstanceMember="${4}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! objectCheckInstanceExists "${typeObject}" "${typeInstanceName}"; then
    messageError "Object type instance is not defined | '${typeObject}.${typeInstanceName}'"
    return "1"
  fi

  if [ ${typeInstanceAction} != "get" ] && [ ${typeInstanceAction} != "set" ] && [ ${typeInstanceAction} != "exec" ]; then
    messageError "Invalid action | '${typeInstanceAction}'; expected 'get', 'set' or 'exec'"
    return "1"
  fi
  local regTypeInstanceMemberName="${typeObject}_${typeInstanceName}_${typeInstanceMember}"
  local currentInstanceMemberValue="${SHELLNS_MAIN_OBJECT_INSTANCES_VALUES[${regTypeInstanceMemberName}]}"


  if [ ${typeInstanceAction} == "get" ] || [ ${typeInstanceAction} == "set" ]; then
    if ! objectCheckTypePropertyExists "${typeObject}" "${typeInstanceMember}"; then
      messageError "Object type property not exists  | '${typeObject}.${typeInstanceMember}'"
      return "1"
    fi

    if [ "${typeInstanceAction}" == "get" ]; then
      echo "${currentInstanceMemberValue}"
    elif [ "${typeInstanceAction}" == "set" ]; then
      local newPropValue="${5}"
      local currentPropType="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}_${typeInstanceMember}_type"]}"
      if ! objectCheckPropertyValue "${currentPropType}" "${newPropValue}"; then
        return "1"
      fi
      
      SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="${newPropValue}"
    fi
  fi



  if [ ${typeInstanceAction} == "exec" ]; then
    if ! objectCheckTypeMethodExists "${typeObject}" "${typeInstanceMember}"; then
      messageError "Object type method not exists | '${typeObject}.${typeInstanceMember}'"
      return "1"
    fi
    shift; shift; shift; shift; 

    local -a arrTypePropNames=()
    local -a arrTypePropValues=()

    objectMetaInstanceProperties "${typeObject}" "${typeInstanceName}" "arrTypePropNames" "arrTypePropValues"

    local -A objectInstanceExecArgs
    objectInstanceExecArgs["typeObject"]="${typeObject}"
    objectInstanceExecArgs["typeInstanceName"]="${typeInstanceName}"

    local it=""
    local typePropName=""
    local typePropValue=""
    local regTypeInstancePropName=""
    for it in "${!arrTypePropNames[@]}"; do
      typePropName="${arrTypePropNames[${it}]}"
      typePropValue="${arrTypePropValues[${it}]}"
      objectInstanceExecArgs["${typePropName}"]="${typePropValue}"
    done    

    $currentInstanceMemberValue  "objectInstanceExecArgs" "$@"
  fi
}




