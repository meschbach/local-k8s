#!/bin/bash

function extract_secret() {
    local namespace=${1:-"default"}; shift
    local name=${1:-"default"}; shift
    local key=${1:-""}; shift

    kubectl get secret $name --namespace $namespace -o json |jq -r ".data[\"${key}\"]" |base64 -d
}

function argo_json() {
    echo "{
  \"address\": \"http://$(svc_address argocd argocd-server name http)\",
  \"user\": \"admin\",
  \"password\": \"$(extract_secret argocd argocd-initial-admin-secret password)\"
}"
}

function svc_address() {
    local NAMESPACE=${1:-"default"} ; shift
    local SVC=${1:-"default"} ; shift
    local PORT_INDEX=${1:-"0"} ; shift
    local MAYBE_NAME=${1:-"optional"} ; shift  # only extracted when PORT_INDEX is name

    status=$(kubectl get svc --namespace $NAMESPACE $SVC -o json)

    if [ "$PORT_INDEX" = "name" ]; then
      PORT_INDEX=$(jq ".spec.ports |map(.name == \"${MAYBE_NAME}\") |index(true)" <<<$status)
    fi

    local port=$(jq ".spec.ports[${PORT_INDEX}].port" <<<$status)
    local address=$(jq -r '.status.loadBalancer.ingress[0].ip' <<<$status)
    echo "${address}:${port}"
}
