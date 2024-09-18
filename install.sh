#!/bin/bash

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f root.yaml

# TODO: wait on the `argocd-initial-admin-secret` to be created after the pods get started.
argocd admin initial-password -n argocd