#!/usr/bin/env bash

#
#
declare -ga OOP_BURL_ALLOWED_HTTP_VERBS=("GET" "POST" "PUT" "PATCH" "DELETE" "HEAD" "OPTIONS" "CONNECT" "TRACE")





#
# Set header value.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Assoc usage mode (set, unset).
#
# @param string $2
# Assoc key name.
#
# @param string $2
# Assoc key value.
#
# @return status+string
burlSetHeader() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local -n tmpAssoc="${regTypeInstanceMemberName}"

  local strSetMode="${1}"
  local strKeyName="${2}"
  local strKeyValue="${3}"

  case "${strSetMode}" in
    "set")
      if [ "${strKeyName}" == "" ] || [[ ! "${strKeyName}" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        messageError "Invalid header name | '${strKeyName}'"
        return "1"
      fi

      tmpAssoc["${strKeyName}"]="${strKeyValue}"
      ;;

    "unset")
      unset tmpAssoc["${strKeyName}"]
      ;;

    "clear")
      local it=""
      for it in "${!tmpAssoc[@]}"; do
        unset tmpAssoc["${it}"]
      done
      ;;

    *)
      messageError "Invalid assoc mode | '${strSetMode}'; expected 'set', 'unset' or 'clear'"
      return "1"
      ;;
  esac

  return "0"
}
#
# Print all headers in HTTP expected format.
#
# @return status
burlPrintHeaders() {
  local -n assocProp="${1}"; shift;
  local -n tmpAssoc="${assocProp["header"]}"


  local key=""
  local value=""
  local httpHeaders=""

  local sortedKeys=($(for it in "${!tmpAssoc[@]}"; do echo "${it}"; done | sort))
  for key in "${sortedKeys[@]}"; do
    value="${tmpAssoc[${key}]}"
    httpHeaders+="${key}: ${value}\r\n"
  done
  
  echo "${httpHeaders}"
  return "0"
}





#
# Set for 'verb' property.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Value to be set.
#
# @return status+string
burlSetVerb() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local strTmpSet=$(stringTrim "${1^^}")


  if [[ ! " ${OOP_BURL_ALLOWED_HTTP_VERBS[*]} " =~ " ${strTmpSet} " ]]; then
    messageError "Invalid http verb | '${1}'"
    return "1"
  fi

  SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="${strTmpSet}"
}





#
# Set for 'protocol' property.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Value to be set.
#
# @return status+string
burlSetProtocol() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local strTmpSet="${1,,}"


  if [ "${strTmpSet}" != "http" ] && [ "${strTmpSet}" != "https" ]; then
    messageError "Invalid protocol | '${1}'; expected 'http' or 'https"
    return "1"
  fi

  SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="${strTmpSet}"
}





#
# Set for 'protocolVersion' property.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Value to be set.
#
# @return status+string
burlSetProtocolVersion() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local strTmpSet="${1}"


  if [ "${strTmpSet}" == "" ]; then
    strTmpSet="1.1"
  else
    local regex='^(0\.9|1\.0|1\.1|2|3)$'

    if ! [[ "${strTmpSet}" =~ $regex ]]; then
      messageError "Invalid protocol version | '${1}'"
      return "1"
    fi
  fi

  SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="${strTmpSet}"
}





#
# Set for 'domain' property.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Value to be set.
#
# @return status+string
burlSetDomain() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local strTmpSet="${1}"

  while [ "${strTmpSet: 1:1}" == "/" ] || [ "${strTmpSet: -1:1}" == "/" ]; do
    strTmpSet="${strTmpSet##/}"
    strTmpSet="${strTmpSet%%/}"
  done


  if [ "${strTmpSet}" != "" ]; then
    local regex='^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'

    if ! [[ "${strTmpSet}" =~ $regex ]]; then
      messageError "Invalid url domain | '${1}'"
      return "1"
    fi
  fi

  SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="${strTmpSet}"
}





#
# Set for 'port' property.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Value to be set.
#
# @return status+string
burlSetPort() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local strTmpSet="${1}"


  if [ "${strTmpSet}" == "" ]; then
    strTmpSet="80"
  else
    if ! varIsInt "${strTmpSet}"; then
      messageError "Invalid port | '${1}'; expected integer."
      return "1"
    else
      if [ "${strTmpSet}" -lt "1" ] || [ "${strTmpSet}" -gt "65535" ]; then
        messageError "Invalid port | '${1}'; expected integer between '1' and '65535'."
        return "1"
      fi
    fi
  fi

  SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="${strTmpSet}"
}





#
# Set for 'path' property.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Value to be set.
#
# @return status+string
burlSetPath() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local strTmpSet="${1}"

  while [ "${strTmpSet: 1:1}" == "/" ] || [ "${strTmpSet: -1:1}" == "/" ]; do
    strTmpSet="${strTmpSet##/}"
    strTmpSet="${strTmpSet%%/}"
  done


  if [ "${strTmpSet}" != "" ]; then
    local regex='^[a-zA-Z0-9._/ -]+$'
    local tmpStr=$(stringRemoveGlyphs "${strTmpSet}")

    if ! [[ "${tmpStr}" =~ $regex ]]; then
      messageError "Invalid url path | '${1}'"
      return "1"
    fi
  fi

  SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="/${strTmpSet}"
}





#
# Set for 'querystring' property.
#
# @param string $1
# Assoc usage mode (set, unset).
#
# @param string $2
# Assoc key name.
#
# @param string $2
# Assoc key value.
#
# @return status+string
burlSetQuerystring() {
  local -n assocProp="${1}"; shift;
  local regTypeInstanceMemberName="${assocProp[_runtimeRegTypeInstanceMemberName]}"
  local -n tmpAssoc="${regTypeInstanceMemberName}"

  local strSetMode="${1}"
  local strKeyName="${2}"
  local strKeyValue="${3}"


  case "${strSetMode}" in
    "set")
      if [ "${strKeyName}" == "" ] || [[ ! "${strKeyName}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        messageError "Invalid querystring key | '${strKeyName}'"
        return "1"
      fi

      tmpAssoc["${strKeyName}"]="${strKeyValue}"
      ;;

    "unset")
      unset tmpAssoc["${strKeyName}"]
      ;;

    "clear")
      local it=""
      for it in "${!tmpAssoc[@]}"; do
        unset tmpAssoc["${it}"]
      done
      ;;

    *)
      messageError "Invalid assoc mode | '${strSetMode}'; expected 'set', 'unset' or 'clear'"
      return "1"
      ;;
  esac

  return "0"
}
#
# Print all querystring in HTTP expected format.
#
# @return status
burlPrintQuerystrings() {
  local -n assocProp="${1}"; shift;
  local -n tmpAssoc="${assocProp["querystring"]}"


  local key=""
  local value=""
  local httpQuerystrings=""

  local sortedKeys=($(for it in "${!tmpAssoc[@]}"; do echo "${it}"; done | sort))
  for key in "${sortedKeys[@]}"; do
    value="${tmpAssoc[${key}]}"
    httpQuerystrings+="${key}=${value}&"
  done

  if [ "${httpQuerystrings}" != "" ]; then
    httpQuerystrings="${httpQuerystrings::-1}"
  fi

  echo "${httpQuerystrings}"
  return "0"
}





#
# Clear all object properties returning then to its default values
#
# @param string $1
# Name of associative array with the current object values.
#
# @return status+string
burlClear() {
  local -n assocProp="${1}"; shift;
  local typeObject="${assocProp["_runtimeTypeObject"]}"
  local typeInstanceName="${assocProp["_runtimeTypeInstanceName"]}"
  local typeInstanceMemberName=""
  local regTypeInstanceMemberName=""

  for typeInstanceMemberName in "${!assocProp[@]}"; do
    regTypeInstanceMemberName="${typeObject}_${typeInstanceName}_${typeInstanceMemberName}"
    
    case "${typeInstanceMemberName}" in
      "header")
        varAssocClear "${SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]}"
        ;;
      "verb")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="GET"
        ;;
      "protocol")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="http"
        ;;
      "protocolVersion")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="1.1"
        ;;
      "domain")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]=""
        ;;
      "port")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="80"
        ;;
      "path")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]=""
        ;;
      "querystring")
        varAssocClear "${SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]}"
        ;;
      "fragment")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]=""
        ;;
    esac
  done

  return "0"
}





#
# Set full URL.
#
# @param string $1
# Name of associative array with the current object values.
#
# @param string $1
# Value to be set.
#
# @return status+string
burlSetURL() {
  local -n assocProp="${1}"; shift;
  local typeObject="${assocProp["_runtimeTypeObject"]}"
  local typeInstanceName="${assocProp["_runtimeTypeInstanceName"]}"
  
  local typeInstanceMemberName=""
  local regTypeInstanceMemberName=""
  local strTmpSet=$(stringTrim "${1}")

  #
  # Reset all properties
  for typeInstanceMemberName in "${!assocProp[@]}"; do
    regTypeInstanceMemberName="${typeObject}_${typeInstanceName}_${typeInstanceMemberName}"
    
    case "${typeInstanceMemberName}" in
      "verb")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="GET"
        ;;
      "protocol")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="http"
        ;;
      "domain")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]=""
        ;;
      "port")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="80"
        ;;
      "path")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]="/"
        ;;
      "querystring")
        varAssocClear "${SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]}"
        ;;
      "fragment")
        SHELLNS_MAIN_OBJECT_INSTANCES_VALUES["${regTypeInstanceMemberName}"]=""
        ;;
    esac
  done


  if [ "${strTmpSet}" != "" ]; then
    local strURL="${strTmpSet}"
    local strValue=""

    local it=""
    for it in "${OOP_BURL_ALLOWED_HTTP_VERBS[@]}"; do
      if [[ "${strURL^^}" == "${it} "* ]]; then
        strValue="${strURL%% *}"
        strURL="${strURL#* }"

        burl ${typeInstanceName} set verb "${strValue}"
        break
      fi
    done


    if [[ "${strURL}" == *"://"* ]]; then
      strValue="${strURL%%://*}"
      strURL="${strURL#*://}"

      burl ${typeInstanceName} set protocol "${strValue}"
    fi

    if [[ "${strURL}" == *"#"* ]]; then
      strValue="${strURL##*#}"
      strURL="${strURL%#*}"

      burl ${typeInstanceName} set fragment "${strValue}"
    fi

    if [[ "${strURL}" == *\?* ]]; then
      strValue="${strURL#*\?}"
      strURL="${strURL%%\?*}"

      if [ "${strValue}" != "" ]; then
        local -a tmpArrQS=()
        IFS='&' read -r -a tmpArrQS <<< "${strValue}"

        local it=""
        local qsKey=""
        local qsValue=""
        for it in "${tmpArrQS[@]}"; do
          qsKey="${it%%=*}"
          qsValue="${it#*=}"

          burl ${typeInstanceName} set querystring set "${qsKey}" "${qsValue}"
        done
      fi
    fi

    if [[ "${strURL}" == */* ]]; then
        strValue="${strURL#*/}"
        strURL="${strURL%%/*}"

        burl ${typeInstanceName} set path "${strValue}"
    fi

    if [[ ! "${strURL}" == *:* ]]; then
      burl ${typeInstanceName} set domain "${strURL}"
    else
      strValue="${strURL%%:*}"
      burl ${typeInstanceName} set domain "${strValue}"

      strValue="${strURL#*:}"
      burl ${typeInstanceName} set port "${strValue}"
    fi
  fi

  return "0"
}





#
# Print the current full URL.
#
# @param string $1
# Name of associative array with the current object values.
#
# @return status+string
burlPrintURL() {
  local -n assocProp="${1}"; shift;
  local typeObject="${assocProp["_runtimeTypeObject"]}"
  local typeInstanceName="${assocProp["_runtimeTypeInstanceName"]}"


  local protocol="${assocProp["protocol"]}"
  local domain="${assocProp["domain"]}"
  local port="${assocProp["port"]}"
  local path="${assocProp["path"]}"
  local querystring=$(burl ${typeInstanceName} exec printQuerystrings)
  local fragment="${assocProp["fragment"]}"
  

  local strURL=""
  if [ "${domain}" != "" ]; then
    local strURL="${protocol}://${domain}"

    if [[ "${protocol}" == "http" && "${port}" != "80" ]] || [[ "${protocol}" == "https" && "${port}" != "443" ]]; then
      strURL+=":${port}"
    fi

    strURL+="${path}"

    if [ "${querystring}" != "" ]; then
      strURL+="?${querystring}"
    fi

    if [ "${fragment}" != "" ]; then
      strURL+="#${fragment}"
    fi
  fi

  echo "${strURL}"
  return "0"
}





#
# Perform a HTTP request.
#
# @param string $1
# Target URL.
# If empty, will use the current value
#
# @param string $2
# Output type.
#
# Expected options:
# - stdout | ''
#   print the httpResponse in the stdout.
#
# - assoc
#   fill in the indicated associative array separating the content into the 
#   following keys: 'headers', 'verb', 'protocol', 'protocolVersion', 
#   'domain', 'port', 'path', 'querystring', 'fragment', 'responseHeaders'
#   and 'responseBody'.
#
# - file
#   put the requested body in the target file.
#   if this file already exist, their content will be overrited.
#
# @param string $3
# Must match what is defined in '$2'. 
#
# If '$2 = stdout' you can indicate here 'body', 'headers', or 'all' 
# (default) to choose just one part or another of the obtained response.
#
# If '$2 = assoc', it must be the name of an associative array that will 
# receive the data from the request made. 
#
# If '$2 = file', it must point to a valid location where a file with the 
# body data of the request will be saved.
# If no target file is defined, then will save a file in the current 
# directory with the predefined name:
# - $(date +'%Y-%m-%d_%H-%M-%S')_response.html
#
# @return status+string
burlRequest() {
  local -n assocProp="${1}"; shift;
  local typeObject="${assocProp["_runtimeTypeObject"]}"
  local typeInstanceName="${assocProp["_runtimeTypeInstanceName"]}"
  local typeInstanceMemberName=""
  local regTypeInstanceMemberName=""
  local _runtimeObjectInstanceExecArgs="${assocProp["_runtimeObjectInstanceExecArgs"]}"



  #
  # If new URL has set... update object and the 'assocProp'
  if [ "${1}" != "" ]; then
    burl "${typeInstanceName}" exec setURL "${1}"

    local -A tmpAssocProp
    objectInstanceFillInternalMethodMainArg "${typeObject}" "${typeInstanceName}" "" "tmpAssocProp"
    varAssocClear "${_runtimeObjectInstanceExecArgs}"

    for it in "${!tmpAssocProp[@]}"; do
      assocProp["${it}"]="${tmpAssocProp["${it}"]}"
    done
  fi



  local strOutputType=$(stringTrim "${2}")
  if [ "${strOutputType}" == "" ]; then
    strOutputType="stdout"
  fi
  if [ "${strOutputType}" != "stdout" ] && [ "${strOutputType}" != "assoc" ] && [ "${strOutputType}" != "file" ]; then
    messageError "Invalid outputtype | '${strOutputType}'; expected 'stdout', 'assoc' or 'file'"
    return "1"
  fi



  local strOutputTarget=$(stringTrim "${3}")
  case "${strOutputType}" in
    "stdout")
      if [ "${strOutputTarget}" != "headers" ] && [ "${strOutputTarget}" != "body" ]; then
        strOutputTarget="all"
      fi
      ;;

    "assoc")
      if ! varIsAssoc "${strOutputTarget}"; then
        messageError "Assoc not exists or is not an assoc array | '${strOutputTarget}'"
        return "1"
      fi
      ;;

    "file")
      local strOutputTargetDir=""

      if [ "${strOutputTarget}" == "" ]; then
        strOutputTargetDir="${PWD}"
        strOutputTarget="$(date +'%Y-%m-%d_%H-%M-%S')_response.html"
      else
        strOutputTargetDir="$(tmpPath=$(dirname "${strOutputTarget}"); realpath "${tmpPath}")"
      fi
      
      if [ ! -d "${strOutputTargetDir}" ]; then
        messageError "Target directory does not exists | '${strOutputTargetDir}'"
        return "1"
      fi
      
      if [ ! -f "${strOutputTarget}" ]; then
        echo "" > "${strOutputTarget}"
        if [ "$?" != "0" ]; then
          messageError "It was not possible to create/edit the indicated file. | '${strOutputTarget}'"
          return "1"
        fi
      fi
      ;;
  esac
  



  local headers=$(burl "${typeInstanceName}" exec printHeaders)
  local verb="${assocProp["verb"]}"
  local protocol="${assocProp["protocol"]}"
  local protocolVersion="${assocProp["protocolVersion"]}"
  local domain="${assocProp["domain"]}"
  local port="${assocProp["port"]}"
  local path="${assocProp["path"]}"
  local querystring=$(burl ${typeInstanceName} exec printQuerystrings)
  local fragment="${assocProp["fragment"]}"


  #
  # Prepends the first required Header
  local initialHeaders=""
  initialHeaders+="${verb} ${path} HTTP/${protocolVersion}\r\n"
  initialHeaders+="Host: ${domain}\r\n"
  initialHeaders+="User-Agent: bash-script\r\n"
  initialHeaders+="Accept: */*\r\n"
  initialHeaders+="Connection: close\r\n"

  local requestHeaders=$(echo -e "${initialHeaders}${headers}\r\n")


  


  #
  # Open the bidirecional socket to target domain/port
  exec 3<> "/dev/tcp/${domain}/${port}"
  #
  # Send headers
  echo "${requestHeaders}" >&3
  #
  # Read data
  local httpInHeaders="1"
  local httpResponseLine=""
  local httpResponseTrimLine=""
  
  local httpResponseHeaders=""
  local httpResponseBody=""
  while IFS='' read -r httpResponseLine <&3; do
    if [ "${httpInHeaders}" == "1" ]; then
      httpResponseTrimLine=$(stringTrim "${httpResponseLine}")
      if [ "${httpResponseTrimLine}" == "" ]; then
        httpInHeaders="0"
      else
        httpResponseHeaders+="${httpResponseLine}\n"
      fi
    else
      httpResponseBody+="${httpResponseLine}\n"
    fi
  done
  #
  # Close socket
  exec 3>&-


  httpResponseHeaders=$(stringTrim "${httpResponseHeaders}")
  httpResponseBody=$(stringTrim "${httpResponseBody}")
  
  case "${strOutputType}" in
    "stdout")
      case "${strOutputTarget}" in
        "headers")
          echo -ne "${httpResponseHeaders}"
          ;;

        "body")
          echo -ne "${httpResponseBody}"
          ;;

        *)
          echo -ne "${httpResponseHeaders}"
          echo -ne "\n\n"
          echo -ne "${httpResponseBody}"
          ;;
      esac
      echo -e "${httpResponseLine}"

      return "0"
      ;;

    "assoc")
      local -n tmpAssocResponse="${strOutputTarget}"

      tmpAssocResponse["headers"]="${requestHeaders}"
      tmpAssocResponse["verb"]="${verb}"
      tmpAssocResponse["protocol"]="${protocol}"
      tmpAssocResponse["protocolVersion"]="${protocolVersion}"
      tmpAssocResponse["domain"]="${domain}"
      tmpAssocResponse["port"]="${port}"
      tmpAssocResponse["path"]="${path}"
      tmpAssocResponse["querystring"]="${querystring}"
      tmpAssocResponse["fragment"]="${fragment}"

      tmpAssocResponse["responseHeaders"]="${httpResponseHeaders}"
      tmpAssocResponse["responseBody"]="${httpResponseBody}"

      return "0"
      ;;

    "file")
      echo -ne "${httpResponseBody}" > "${strOutputTarget}"
      return "$?"
      ;;
  esac
}





#
# Definition of type
objectTypeCreate burl

#
# Properties
objectTypeSetProperty burl assoc header "" burlSetHeader
objectTypeSetProperty burl string verb "GET" burlSetVerb
objectTypeSetProperty burl string protocol "http" burlSetProtocol
objectTypeSetProperty burl string protocolVersion "1.1" burlSetProtocolVersion
objectTypeSetProperty burl string domain "" burlSetDomain
objectTypeSetProperty burl int port "80" burlSetPort
objectTypeSetProperty burl string path "/" burlSetPath
objectTypeSetProperty burl assoc querystring "" burlSetQuerystring
objectTypeSetProperty burl string fragment ""

#
# Methods
objectTypeSetMethod burl clear burlClear
objectTypeSetMethod burl printHeaders burlPrintHeaders
objectTypeSetMethod burl printQuerystrings burlPrintQuerystrings
objectTypeSetMethod burl setURL burlSetURL
objectTypeSetMethod burl printURL burlPrintURL
objectTypeSetMethod burl request burlRequest

#
# End definition
objectTypeCreateEnd burl