#!/bin/bash

kubectl get secrets -n grafana grafana -o json |jq -r '.data["admin-password"]'|base64 -d