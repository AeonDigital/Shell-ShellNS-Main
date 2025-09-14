#!/usr/bin/env bash

#
unset SHELLNS_CORE_MESSAGE_SYMBOL
declare -gA SHELLNS_CORE_MESSAGE_SYMBOL
SHELLNS_CORE_MESSAGE_SYMBOL["error"]="[ x ]"
SHELLNS_CORE_MESSAGE_SYMBOL["info"]="[ i ]"
SHELLNS_CORE_MESSAGE_SYMBOL["warning"]="[ ! ]"
SHELLNS_CORE_MESSAGE_SYMBOL["success"]="[ v ]"

#
unset SHELLNS_CORE_MESSAGE_PREFIX
declare -gA SHELLNS_CORE_MESSAGE_PREFIX
SHELLNS_CORE_MESSAGE_PREFIX["error"]="Error"
SHELLNS_CORE_MESSAGE_PREFIX["info"]="Info"
SHELLNS_CORE_MESSAGE_PREFIX["warning"]="Warning"
SHELLNS_CORE_MESSAGE_PREFIX["success"]="Success"


#
# Show a message to the standard output.
#
# @param string $1
# Message type. Possible values are: error, info, warning, success.
#
# @param string $2
# Message text.
#
# @return string
messageShow() {
  local msgType="${1}"
  local msgText="${2}"

  if [ "${msgType}" == "" ] || [ "${msgText}" == "" ]; then
    echo "[ x ] Error: Invalid message type or text!" >&2
    return "1"
  fi

  local msgSymbol="${SHELLNS_CORE_MESSAGE_SYMBOL[${msgType}]}"
  local msgPrefix="${SHELLNS_CORE_MESSAGE_PREFIX[${msgType}]}"

  if [ "${msgSymbol}" == "" ] || [ "${msgPrefix}" == "" ]; then
    echo "[ x ] Error: Unknown message type '${msgType}'!" >&2
    return "1"
  fi


  if [ "${msgType}" == "error" ]; then
    echo "${msgSymbol} ${msgPrefix}: ${msgText}" >&2
    return "0"
  fi

  echo "${msgSymbol} ${msgPrefix}: ${msgText}" >&1
  return "0"
}


#
# Print an error message to the standard output.
#
# @param string $1
# Message to print.
#
# @return string
messageError() {
  messageShow "error" "${1}"
}

#
# Print an warning message to the standard output.
#
# @param string $1
# Message to print.
#
# @return string
messageInfo() {
  messageShow "info" "${1}"
}

#
# Print an warning message to the standard output.
#
# @param string $1
# Message to print.
#
# @return string
messageWarning() {
  messageShow "warning" "${1}"
}

#
# Print an success message to the standard output.
#
# @param string $1
# Message to print.
#
# @return string
messageSuccess() {
  messageShow "success" "${1}"
}