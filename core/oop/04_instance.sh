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
  local instanceName="${2}"

  if ! objectCheckTypeExists "${typeObject}"; then
    messageError "Object type is not defined | '${typeObject}'"
    return "1"
  fi

  if [ "${instanceName}" == "" ] ||  [[ ! "${instanceName}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    messageError "Invalid instance name | '${instanceName}'"
    return "1"
  fi

  if objectCheckInstanceExists "${typeObject}" "${instanceName}"; then
    messageError "Instance alread exists | '${typeObject}.${instanceName}'"
    return "1"
  fi

  local registerName="${typeObject}_${instanceName}"
  SHELLNS_MAIN_OBJECT_INSTANCES["${typeObject}"]+="${instanceName};"
  SHELLNS_MAIN_OBJECT_INSTANCES["${registerName}"]="-"

  return "0"
}





objectInstanceSetProperty() {
  echo "1"
}

objectInstanceGetProperty() {
  echo "2"
}

objectInstanceExecMethod() {
  echo "3"
}