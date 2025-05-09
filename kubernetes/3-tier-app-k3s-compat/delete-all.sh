#!/usr/bin/bash

kubectl delete -f ./mysql-configmap.yaml
kubectl delete -f ./db-credentials-secret.yaml
kubectl delete -f ./db-root-credentials-secret.yaml
kubectl delete -f ./mysql-statefulset.yaml

kubectl delete -f ./backend-configmap.yaml
kubectl delete -f ./backend-deployment.yaml

kubectl delete -f ./frontend-deployment.yaml
