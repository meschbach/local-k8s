#!/bin/bash

set -xe
if [ -d .secrets ]; then
  echo "Secrets directory exists."
else
  mkdir -p .secrets
fi

# TODO: better if we used the keychain
pg_16_4_postgres_file=".secrets/pg-16"
if [ -f "$pg_16_4_postgres_file" ]; then
  echo "Postgres secrets already exists"
else
  # from https://www.markusdosch.com/2022/05/generating-a-random-string-on-linux-macos/
  cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1 >"$pg_16_4_postgres_file"
fi

if [ $(kubectl get ns |grep pg-16-4 | wc -l) = 0 ]; then
  kubectl create namespace pg-16-4
fi

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
