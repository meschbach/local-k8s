#!/bin/bash

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f root.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

while [ -z $(kubectl get secrets -n argocd |grep initial-admin-secret |wc -l) ];
  sleep 5
done

./postgres-password.sh

# TODO: wait on the `argocd-initial-admin-secret` to be created after the pods get started.
argocd admin initial-password -n argocd
