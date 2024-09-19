#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/common.sh"

subarg=${1:-help}; shift

set -e
case "${subarg}" in
  "help")
    cat <<EOF
Usage: ${0} <subcommand>
Where 'subcommand' can be:
  * install - Performs initial install or updates the system to the latest root descriptor
  * argocd - Provides connection string for argocd
  * services - JSON document of exported services by ${0}
EOF
  exit 0
  ;;
  "argocd")
    argo_json
  ;;
  "services")
    services_json
  ;;
  "create-db")
    create_db $1
  ;;
  "delete-db")
    delete_db $1
  ;;
  "db-pgx-string")
    db_connection_env $1
  ;;
  "install")
    cmd_install
  ;;
  *)
    echo "Unkonwn.  Try 'help'"
    exit -2
  ;;
esac
