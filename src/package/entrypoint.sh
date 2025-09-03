#!/usr/bin/env bash

#
# Starts this package in the context of the shell.
#
# @param dirExistentFullPath $1
# Path to the root directory of the current package.
#
# @param string $2
# Type of execution. Choose one of : **load**, **export** or  **utests**
#
# @return void
shellNS_main_package_entrypoint() {
  local pathToCurrentPackageDir="${1}"

  case "${2}" in
    "install")
      shellNS_main_boot_executeScript "standalone/install.sh" "shellNS_standalone_install" "install"
      ;;

    "uninstall")
      shellNS_main_boot_executeScript "standalone/uninstall.sh" "shellNS_standalone_uninstall" "uninstall"
      ;;

    "update")
      shellNS_main_boot_executeScript "standalone/uninstall.sh" "shellNS_standalone_uninstall" "update"
      if [ $(statusGet) == "0" ]; then
        unset SHELLNS_MAIN_DEPENDENCIES["shellns_utest_standalone.sh"]
        shellNS_main_boot_executeScript "standalone/install.sh" "shellNS_standalone_install" "update"
      fi
      ;;


    "utest")
      shellNS_main_boot_executeScript "standalone/install.sh" "shellNS_standalone_install" "install" "1" "1"
      shellNS_main_boot_executeScript "utest/execute.sh" "shellNS_utest_execute" "${2}" "${3}" "${4}"
      ;;


    "export")
      shellNS_main_boot_executeScript "standalone/export.sh" "shellNS_standalone_export"
      ;;

    "extract-all")
      shellNS_main_boot_executeScript "standalone/export.sh" "shellNS_standalone_export"
      #shellNS_main_extract_manuals
      #shellNS_main_extract_nsMappings
      ;;


    "run")
      shellNS_main_package_load "${pathToCurrentPackageDir}" "1"
      ;;

    *)
      shellNS_main_package_load "${pathToCurrentPackageDir}" "0"
      ;;
  esac
}