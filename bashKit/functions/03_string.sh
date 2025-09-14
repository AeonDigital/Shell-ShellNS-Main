#!/usr/bin/env bash

#
# Eliminates blank space at the beginning or end of a string.
#
# @param string $1
# String that will be changed.
#
# @return string
# The returned string will have its control characters in
# interpreted format **echo -e**.
stringTrim() {
  local strReturn="${1}"
  strReturn="${strReturn#"${strReturn%%[![:space:]]*}"}" # trim L
  strReturn="${strReturn%"${strReturn##*[![:space:]]}"}" # trim R
  echo -ne "${strReturn}"
}


#
# Eliminates blank space at the beginning or end of a string.
#
# @param string $1
# String that will be changed.
#
# @return string
# The returned string will retain the control characters in
# literal form.
stringTrimRaw() {
  local strReturn="${1}"
  strReturn="${strReturn#"${strReturn%%[![:space:]]*}"}" # trim L
  strReturn="${strReturn%"${strReturn##*[![:space:]]}"}" # trim R
  echo -n "${strReturn}"
}


#
# Eliminates blank space at the beginning of a string.
#
# @param string $1
# String that will be changed.
#
# @return string
# The returned string will have its control characters in
# interpreted format **echo -e**.
stringTrimL() {
  local strReturn="${1}"
  strReturn="${strReturn#"${strReturn%%[![:space:]]*}"}" # trim L
  echo -ne "${strReturn}"
}


#
# Eliminates blank space at the beginning of a string.
#
# @param string $1
# String that will be changed.
#
# @return string
# The returned string will retain the control characters in
# literal form.
stringTrimLRaw() {
  local strReturn="${1}"
  strReturn="${strReturn#"${strReturn%%[![:space:]]*}"}" # trim L
  echo -n "${strReturn}"
}


#
# Eliminates blank space at the end of a string.
#
# @param string $1
# String that will be changed.
#
# @return string
# The returned string will have its control characters in
# interpreted format **echo -e**.
stringTrimR() {
  local strReturn="${1}"
  strReturn="${strReturn%"${strReturn##*[![:space:]]}"}" # trim R
  echo -ne "${strReturn}"
}


#
# Eliminates blank space at the end of a string.
#
# @param string $1
# String that will be changed.
#
# @return string
# The returned string will retain the control characters in
# literal form.
stringTrimRRaw() {
  local strReturn="${1}"
  strReturn="${strReturn%"${strReturn##*[![:space:]]}"}" # trim R
  echo -n "${strReturn}"
}





#
# Pad a string to the left or right with a specific character.
#
# If the string is longer than the specified length, it will be returned unchanged.
#
# @param string $1
# String that will be changed.
#
# @param string $2
# Character that will be used for padding.
#
# @param int $3
# Length of the returned string.
#
# @param string $4
# Position of the padding character.
# Possible values are:
# - 'l' : left
# - 'r' : right
# Default is 'r'.
#
# @param int $5
# If set to **1**, the returned string will retain the control characters in
# literal form. If set to **0** or omitted, the returned string will have its
# control characters in interpreted format **echo -e**.
#
# @return string
stringPadding() {
  local strReturn="${1}"
  local strChar="${2}"
  local strLength="${3}"
  local strPosition="${4,,U}"
  local strReturnRaw="${5}"

  if [ "${strChar}" == "" ]; then
    return "10"
  fi

  if ! [[ "${strLength}" =~ ^-?[0-9]+$ ]]; then
    return "11"
  fi

  if [ "${strPosition}" != "l" ] && [ "${strPosition}" != "r" ]; then
    return "12"
  fi

  if [ "${strReturnRaw}" != "0" ] && [ "${strReturnRaw}" != "1" ]; then
    strReturnRaw="0"
  fi

  local currentLength="${#strReturn}"
  while [ "${currentLength}" -lt "${strLength}" ]; do
    if [ "${strPosition}" == "l" ]; then
      strReturn="${strChar}${strReturn}"
    else
      strReturn="${strReturn}${strChar}"
    fi
    
    currentLength="${#strReturn}"
  done

  if [ "${strReturnRaw}" == "1" ]; then
    echo -n "${strReturn}"
  else 
    echo -ne "${strReturn}"
  fi
}
#
# Wrapper for stringPadding() to pad left.
#
# @param string $1
# String that will be changed.
#
# @param string $2
# Character that will be used for padding.
#
# @param int $3
# Length of the returned string.
#
# @return string
stringPaddingL() {
  stringPadding "${1}" "${2}" "${3}" "l" "0"
}
#
# Wrapper for stringPadding() to pad right.
#
# @param string $1
# String that will be changed.
#
# @param string $2
# Character that will be used for padding.
#
# @param int $3
# Length of the returned string.
#
# @return string
stringPaddingR() {
  stringPadding "${1}" "${2}" "${3}" "r" "0"
}
#
# Wrapper for stringPadding() to pad left with raw output.
#
# @param string $1
# String that will be changed.
#
# @param string $2
# Character that will be used for padding.
#
# @param int $3
# Length of the returned string.
#
# @return string
stringPaddingLRaw() {
  stringPadding "${1}" "${2}" "${3}" "l" "1"
}
#
# Wrapper for stringPadding() to pad right with raw output.
#
# @param string $1
# String that will be changed.
#
# @param string $2
# Character that will be used for padding.
#
# @param int $3
# Length of the returned string.
#
# @return string
stringPaddingRRaw() {
  stringPadding "${1}" "${2}" "${3}" "r" "1"
}





#
# Removes all strings containing glyphs by their respective glyph-free version.
#
# @param string $1
# String that will be changed.
#
# @return string
stringRemoveGlyphs() {
  echo -ne "${1}" | iconv --from-code="UTF8" --to-code="ASCII//TRANSLIT"
}





#
# Capitalizes the first letter of a string and all subsequent ones found after 
# the indicated separator..
#
# @param string $1
# String that will be changed.
#
# @param char $2
# Character used as a separator to indicate that, after it, the first letter 
# should be capitalized.
# If empty, will use space char like default value.
#
# @return string
stringCapitalizeFirst() {
  local str="${1}"
  local sep=$(stringTrim "${2}")
  
  if [ "${sep}" == "" ]; then
    sep=" "
  else
    sep="${sep:0:1}"
  fi

  local strReturn=""
  local -a arrParts=()
  IFS="${sep}" read -ra arrParts <<< "${str}"
  
  local strPart=""
  for strPart in "${arrParts[@]}"; do
    strReturn+="${strPart^}${sep}"
  done

  strReturn="${strReturn%-}"
  echo "${strReturn}"
}