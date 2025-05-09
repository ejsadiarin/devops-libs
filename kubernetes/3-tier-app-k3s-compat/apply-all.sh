#!/usr/bin/bash

kubectl apply -f ./mysql-configmap.yaml
kubectl apply -f ./db-credentials-secret.yaml
kubectl apply -f ./db-root-credentials-secret.yaml
kubectl apply -f ./mysql-statefulset.yaml

kubectl apply -f ./backend-configmap.yaml
kubectl apply -f ./backend-deployment.yaml

kubectl apply -f ./frontend-deployment.yaml
