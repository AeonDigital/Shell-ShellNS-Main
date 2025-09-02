#!/usr/bin/env bash

#
# Starts this package in the context of the shell.
#
# @param dirExistentFullPath $1
# Path to the root directory of the current package.
#
# @param string $2
# Type of execution. 
# - run             : Default action, runs the ShellNS in normal mode.
# - run-pkg         : runs only the current package.
#                     will download all dependencies in standalone mode.
#                     Use for develpment purposes or testing.
# - load
# - export
# - utests
# - install 
# - uninstall 
# - update 
# - utest 
# - export 
# - extract-all 
#
# @return void
shellNS_main_boot_entrypoint() {
  local pathToCurrentPackageDir="${1}"

  case "${2}" in
    ""|"run")
      # Default action 
      shellNS_main_boot_packageLoad "${pathToCurrentPackageDir}" "0"
      ;;

    "run-pkg")
      shellNS_main_boot_packageLoad "${pathToCurrentPackageDir}" "1"
      ;;


    # "install")
    #   shellNS_main_boot_executeScript "standalone/install.sh" "shellNS_standalone_install" "install"
    #   ;;

    # "uninstall")
    #   shellNS_main_boot_executeScript "standalone/uninstall.sh" "shellNS_standalone_uninstall" "uninstall"
    #   ;;

    # "update")
    #   shellNS_main_boot_executeScript "standalone/uninstall.sh" "shellNS_standalone_uninstall" "update"
    #   if [ $(statusGet) == "0" ]; then
    #     unset SHELLNS_MAIN_DEPENDENCIES_REPO_LIST["shellns_utest_standalone.sh"]
    #     shellNS_main_boot_executeScript "standalone/install.sh" "shellNS_standalone_install" "update"
    #   fi
    #   ;;


    # "utest")
    #   shellNS_main_boot_executeScript "standalone/install.sh" "shellNS_standalone_install" "install" "1" "1"
    #   shellNS_main_boot_executeScript "utest/execute.sh" "shellNS_utest_execute" "${2}" "${3}" "${4}"
    #   ;;


    # "export")
    #   shellNS_main_boot_executeScript "standalone/export.sh" "shellNS_standalone_export"
    #   ;;

    # "extract-all")
    #   shellNS_main_boot_executeScript "standalone/export.sh" "shellNS_standalone_export"
    #   #shellNS_main_extract_manuals
    #   #shellNS_main_extract_nsMappings
    #   ;;
  esac

  echo "[ x ] Error: Unknown command '${2}'!"
  return "1"
}