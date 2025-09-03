#!/usr/bin/env bash

#
# Mantain the last registered result status.
unset SHELLNS_CORE_RETURNSTATUS
declare -g SHELLNS_CORE_RETURNSTATUS=""



#
# Example of usage:
#
# ``` shell 
# executeFunction "arg1" "arg2"; statusSet "$?"
# if [ $(statusGet) != "0" ]; then
#   echo "An error occurred!"
# fi
# ```




#
# Store the result status for lazy comparison.
#
# @param int $1
# Status code to store.
#
# @return void
statusSet() {
  SHELLNS_CORE_RETURNSTATUS="${1}"
}

#
# Get the last stored status code.
#
# @return int
statusGet() {
  echo -ne "${SHELLNS_CORE_RETURNSTATUS}"
}