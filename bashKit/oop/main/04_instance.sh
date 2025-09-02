#!/usr/bin/env bash

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
  local typePropType=""
  local typePropName=""
  local typePropDefault=""
  local regTypeInstancePropName=""
  for it in "${!arrTypePropNames[@]}"; do
    typePropType="${arrTypePropTypes[${it}]}"
    typePropName="${arrTypePropNames[${it}]}"
    typePropDefault="${arrTypePropDefault[${it}]}"

    regTypeInstancePropName="${regTypeInstanceName}_${typePropName}"
    if [ "${typePropType}" == "array" ]; then
      typePropDefault="${regTypeInstancePropName}_array"
      declare -ga "${typePropDefault}"
    elif [ "${typePropType}" == "assoc" ]; then
      typePropDefault="${regTypeInstancePropName}_assoc"
      declare -gA "${typePropDefault}"
    fi

    SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstancePropName}"]="${typePropDefault}"
  done



  local -a arrTypeMethodNames=()
  local -a arrTypeMethodFunctions=()
  objectMetaTypeGetMethods "${typeObject}" "arrTypeMethodNames" "arrTypeMethodFunctions"

  local it=""
  local typeMethodName=""
  local typeMethodFunction=""
  local regTypeInstanceMethodName=""
  for it in "${!arrTypeMethodNames[@]}"; do
    typeMethodName="${arrTypeMethodNames[${it}]}"
    typeMethodFunction="${arrTypeMethodFunctions[${it}]}"

    regTypeInstanceMethodName="${regTypeInstanceName}_${typeMethodName}"
    SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMethodName}"]="${typeMethodFunction}"
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
  local typeInstanceMemberName="${4}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! objectCheckInstanceExists "${typeObject}" "${typeInstanceName}"; then
    messageError "Object type instance is not defined | '${typeObject}.${typeInstanceName}'"
    return "1"
  fi

  case "${typeInstanceAction}" in
    "get" | "set")
      if ! objectCheckTypePropertyExists "${typeObject}" "${typeInstanceMemberName}"; then
        messageError "Object type property not exists | '${typeObject}.${typeInstanceMemberName}'"
        return "1"
      fi
      ;;

    "exec")
      if ! objectCheckTypeMethodExists "${typeObject}" "${typeInstanceMemberName}"; then
        messageError "Object type method not exists | '${typeObject}.${typeInstanceMemberName}'"
        return "1"
      fi
      ;;

    *)
      messageError "Invalid action | '${typeInstanceAction}'; expected 'get', 'set' or 'exec'"
      return "1"
      ;;
  esac



  local regTypeInstanceMemberName="${typeObject}_${typeInstanceName}_${typeInstanceMemberName}"
  local currentInstanceMemberValue="${SHELLNS_MAIN_OBJECT_INSTANCES_VALUES[${regTypeInstanceMemberName}]}"
  local currentPropType="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}_${typeInstanceMemberName}_type"]}"



  case "${typeInstanceAction}" in
    "get")
      local currentInstanceMemberGetFn="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}_${typeInstanceMemberName}_get"]}"

      if [ "${currentInstanceMemberGetFn}" != "" ]; then
        typeInstanceAction="exec"
        currentInstanceMemberValue="${currentInstanceMemberGetFn}"
      else

        if [ "${currentPropType}" == "array" ] || [ "${currentPropType}" == "assoc" ]; then
          local newPropArrayGetKey="${5}"
          local -n tmpArr="${currentInstanceMemberValue}"

          if [[ ! -v tmpArr["${newPropArrayGetKey}"] ]]; then
            messageError "Invalid ${currentPropType} key | '${typeInstanceMemberName}.${newPropArrayGetKey}'"
            return "1"
          fi

          echo "${tmpArr[${newPropArrayGetKey}]}"
          return "0"
        fi

        echo "${currentInstanceMemberValue}"
        return "0"
      fi
      ;;

    "set")
      currentInstanceMemberSetFn="${SHELLNS_MAIN_OBJECT_TYPE_PROPERTIES["${typeObject}_${typeInstanceMemberName}_set"]}"

      if [ "${currentInstanceMemberSetFn}" != "" ]; then
        typeInstanceAction="exec"
        currentInstanceMemberValue="${currentInstanceMemberSetFn}"
      else

        if [ "${currentPropType}" == "array" ]; then
          local newPropArraySetMode="${5}"
          local -n tmpArr="${currentInstanceMemberValue}"

          case "${newPropArraySetMode}" in
            "append")
              local newPropArraySetValue="${6}"
              tmpArr+=("${newPropArraySetValue}")
              ;;
            
            "set")
              local newPropArraySetIndex="${6}"
              local newPropArraySetValue="${7}"
              tmpArr["${newPropArraySetIndex}"]="${newPropArraySetValue}"
              ;;
            
            "unset")
              local newPropArraySetIndex="${6}"
              unset tmpArr["${newPropArraySetIndex}"]
              ;;
            
            "clear")
              tmpArr=()
              ;;

            *)
              messageError "Invalid array mode | '${newPropArraySetMode}'; expected 'append', 'set' or 'unset'"
              ;;
          esac

          return "0"
        fi

        if [ "${currentPropType}" == "assoc" ]; then
          local newPropAssocSetMode="${5}"
          local -n tmpAssoc="${currentInstanceMemberValue}"

          case "${newPropAssocSetMode}" in
            "set")
              local newPropArraySetKey="${6}"
              local newPropArraySetValue="${7}"
              tmpAssoc["${newPropArraySetKey}"]="${newPropArraySetValue}"
              ;;

            "unset")
              local newPropArraySetKey="${6}"
              unset tmpAssoc["${newPropArraySetKey}"]
              ;;
            
            "clear")
              local it=""
              for it in "${!tmpAssoc[@]}"; do
                unset tmpAssoc["${it}"]
              done
              ;;
            
            *)
              messageError "Invalid assoc mode | '${newPropAssocSetMode}'; expected 'set', 'unset' or 'clear'"
              ;;
          esac

          return "0"
        fi

        local newPropValue="${5}"
        if ! objectCheckPropertyValue "${currentPropType}" "${newPropValue}"; then
          return "1"
        fi

        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="${newPropValue}"
        return "0"
      fi
    ;;
  esac


  if [ ${typeInstanceAction} == "exec" ]; then
    shift; shift; shift; shift; 

    local -A objectInstanceExecArgs
    objectInstanceFillInternalMethodMainArg "${typeObject}" "${typeInstanceName}" "${typeInstanceMemberName}" "objectInstanceExecArgs"
    
    if [ "${currentPropType}" == "array" ] || [ "${currentPropType}" == "assoc" ]; then
      objectInstanceExecArgs["regTypeInstanceMemberName"]+="_${currentPropType}"
    fi
    
    $currentInstanceMemberValue  "objectInstanceExecArgs" "$@"
  fi
}
#
# Fill the associative array that should be used with the methods of an object 
# instance. 
#
# Each key represents the current value of one of its properties.
#
#
# @param string $1
# Type of the object.
#
# @param string $2
# Name of the instance.
#
# @param string $3
# Property name.
#
# @param string $4
# Name of the associative array thats will be filled.
#
# @return status
objectInstanceFillInternalMethodMainArg() {
  local typeObject="${1}"
  local typeInstanceName="${2}"
  local typeInstanceMemberName="${3}"
  local strTmpAssocName="${4}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if ! objectCheckInstanceExists "${typeObject}" "${typeInstanceName}"; then
    messageError "Object type instance is not defined | '${typeObject}.${typeInstanceName}'"
    return "1"
  fi

  if ! varIsAssoc "${strTmpAssocName}"; then
    messageError "Assoc not exists or is not an assoc array | '${strTmpAssocName}'"
    return "1"
  fi



  local -n tmpAssocArray="${strTmpAssocName}"
  tmpAssocArray["_runtimeTypeObject"]="${typeObject}"
  tmpAssocArray["_runtimeTypeInstanceName"]="${typeInstanceName}"
  tmpAssocArray["_runtimeTypeInstanceMemberName"]="${typeInstanceMemberName}"
  tmpAssocArray["_runtimeRegTypeInstanceMemberName"]="${typeObject}_${typeInstanceName}_${typeInstanceMemberName}"
  tmpAssocArray["_runtimeObjectInstanceExecArgs"]="${strTmpAssocName}"
  

  local -a arrTypePropNames=()
  local -a arrTypePropValues=()

  objectMetaInstanceProperties "${typeObject}" "${typeInstanceName}" "arrTypePropNames" "arrTypePropValues"

  local it=""
  local typePropName=""
  local typePropValue=""
  local regTypeInstancePropName=""
  for it in "${!arrTypePropNames[@]}"; do
    typePropName="${arrTypePropNames[${it}]}"
    typePropValue="${arrTypePropValues[${it}]}"
    tmpAssocArray["${typePropName}"]="${typePropValue}"
  done

  return "0"
}