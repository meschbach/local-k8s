#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/common.sh"

NAMESPACE=${1:-"default"} ; shift
SVC=${1:-"default"} ; shift
PORT_INDEX=${1:-"0"} ; shift
MAYBE_NAME=${1:-"optional"} ; shift  # only extracted when PORT_INDEX is name

svc_address $NAMESPACE $SVC $PORT_INDEX $MAYBE_NAME
