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

function services_json() {
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
  },
  \"nats\": {
    \"address\": \"$(svc_address argocd cluster-nats-app name nats)\"
  }
}"
}

function cmd_install() {
  set -e
  ensure_namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.12.6/manifests/install.yaml
  kubectl apply -f root.yaml
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

  echo ""
  echo "Waiting for ArgoCD to come online"
  echo ""
  while [ -z $(kubectl get secrets -n argocd |grep initial-admin-secret |wc -l) ]; do
    sleep 5
  done

  #
  # Setup Postgres 16.4 cluster
  #
  postgres_password

  echo "Completed"
}

function postgres_password() {
    # TODO: better if we used the keychain
    if [ -d "$SCRIPT_DIR/.secrets" ]; then
      echo "Secrets directory exists."
    else
      mkdir -p "$SCRIPT_DIR/.secrets"
    fi

    pg_16_4_postgres_file="$SCRIPT_DIR/.secrets/pg-16"
    if [ -f "$pg_16_4_postgres_file" ]; then
      echo "Postgres secrets already exists"
    else
      # from https://www.markusdosch.com/2022/05/generating-a-random-string-on-linux-macos/
      cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1 >"$pg_16_4_postgres_file"
    fi

    ensure_namespace pg-16-4

    # Update the secret
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cluster-pgdb
  namespace: pg-16-4
type: Opaque
stringData:
  password: "$(cat ${pg_16_4_postgres_file})"
  host: pg-16-4.pg-16-4.svc.cluster.local
  user: postgres
  port: "5432"
  database: postgres
EOF
}

function ensure_namespace() {
  ns="$1"

  kubectl get namespace | grep -q "^$ns " || kubectl create namespace $ns
}

function create_db() {
  local db_name=${1:-default-db}; shift

  kubectl apply -f - <<EOF
apiVersion: pgdb.storage.meschbach.com/v1alpha1
kind: Database
metadata:
  name: "$db_name"
  namespace: default
spec:
  allowPasswordSpecials: false
  clusterNamespace: pg-16-4
  clusterSecret: cluster-pgdb
  controller: default
  databaseSecret: "$db_name"
EOF
}

function delete_db() {
  local db_name=${1:-default-db}; shift

  kubectl delete database $db_name
}

function db_connection_env() {
  local db_name=${1:-default-db}; shift
  local svc=$(services_json)
  local secret_name=$(kubectl get database $db_name -o json |jq -r '.status["database-secret"]')
  local database=$(extract_secret default $secret_name user)
  local user=$(extract_secret default $secret_name user)
  local pass=$(extract_secret default $secret_name password)
  local hostport=$(jq -r '.postgres.address' <<<$svc)
  echo "postgres://${user}:${pass}@${hostport}/${database}"
}

function cmd_up() {
     minikube start --driver=qemu  --network socket_vmnet --service-cluster-ip-range 10.112.0.0/12
     cmd_install
}

function cmd_down() {
  minikube delete
}

function cmd_addons_root() {
  verb=${1:-help}; shift || true
  name=${1:-reserved}; shift || true
  echo "addons ${verb} ${name}"

  case "${verb}" in
  "install")
    echo "Installing $name"
    (
    cd $SCRIPT_DIR/addons/$name
    source "./hooks.sh"
    cmd_addon_up
    )
  ;;
  "remove")
    echo "Removing $name"
    (
    cd $SCRIPT_DIR/addons/$name
    source "./hooks.sh"
    cmd_addon_down
    )
  ;;
  *)
    echo "Usage: local-k8s addons [install/remove] <name>"
    ;;
  esac
}