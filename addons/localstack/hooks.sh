#!/bin/bash

function cmd_addon_up() {
  kubectl apply -f localstack.yaml
}

function cmd_addon_down() {
  kubectl delete -f localstack.yaml
}

function cmd_root() {
    local subarg=${1:-help}; shift

    case "$subarg" in
    "envlocal")
      prefix="$1"
      addr=$(svc_address localstack addon-localstack name edge)
      echo "${prefix}AWS_ACCESS_KEY_ID=test"
      echo "${prefix}AWS_SECRET_ACCESS_KEY=test"
      echo "${prefix}AWS_REGION=us-east-1"
      echo "${prefix}AWS_ENDPOINT_URL=http://$addr"
    ;;
    "op")
      # execute in subshell
      (
      export AWS_ACCESS_KEY_ID=test
      export AWS_SECRET_ACCESS_KEY=test
      export AWS_REGION=us-east-1
      export AWS_ENDPOINT_URL=http://$(svc_address localstack addon-localstack name edge)
      aws --endpoint $AWS_ENDPOINT_URL "$@"
      )
    ;;
    *)
      echo "Valid subcommands:"
      echo "* envlocal - AWS Environment config suitable for consumption in env file"
    ;;
    esac
}