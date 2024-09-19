#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/common.sh"

echo "{
  \"argocd\": $(argo_json),
  \"postgres\" : {
    \"address\": \"$(svc_address pg-16-4 pg-16-4-lb name postgres)\",
    \"user\": \"$(extract_secret pg-16-4 cluster-pgdb user)\",
    \"password\": \"$(extract_secret pg-16-4 cluster-pgdb password)\",
    \"database\": \"$(extract_secret pg-16-4 cluster-pgdb database)\"
  },
  \"otlp\": {
    \"address\": \"$(svc_address grafana-tempo grafana-tempo name grpc-tempo-otlp)\"
  },
  \"grafana\": {
    \"address\": \"http://$(svc_address grafana grafana name service)\",
    \"user\": \"$(extract_secret grafana grafana admin-user)\",
    \"password\": \"$(extract_secret grafana grafana admin-password)\"
  }
}"
