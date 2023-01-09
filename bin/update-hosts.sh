#!/bin/bash

SCRIPT_NAME=`basename "${0}"`

remainingArgs=()
while [[ $# -gt 0 ]]; do
  arg="$1"

  case $arg in
    -d|--domain)
      DOMAIN="${2}"
      shift
    ;;
    -h|--help)
      SHOW_HELP='true'
      shift
    ;;
    *)
    # store remaining args in Array
    remainingArgs+=("$1")
    shift
    ;;
  esac
done

# Displaying the `help` info is a one-time operation, so just show and exit the
# script.
if [[ -n "$SHOW_HELP" ]]; then
  echo;
  echo " usage: ${SCRIPT_NAME} [OPTIONS] [ARGS]"
  echo "        ${SCRIPT_NAME} -d app.local"
  echo;
  echo " -d, --domain ... A local domain name"
  echo " -h, --help ..... Displays info on how to run this script"
  exit 0;
fi

if [[ "$DOMAIN" == "" ]]; then
  echo "[ERROR] No host name provided\n   example: ${SCRIPT_NAME} -d \"app.local\""
  exit 1
fi

HOSTS_FILE_LOCATION="/etc/hosts"
if [[ "${WSL_DISTRO_NAME}" != "" ]]; then
  HOSTS_FILE_LOCATION="/c/Windows/System32/drivers/etc/hosts"
fi

HOST_ENTRY="127.0.0.1 ${DOMAIN}"
result=$(cat "${HOSTS_FILE_LOCATION}" | grep "${HOST_ENTRY}")
if [[ "${result}" == "" ]]; then
  echo "[ADD] New vhost entry to your hosts file"
  echo "${HOST_ENTRY}" | sudo tee -a "${HOSTS_FILE_LOCATION}"
fi
echo "[VIEW] Current hosts entries"
cat "${HOSTS_FILE_LOCATION}"
