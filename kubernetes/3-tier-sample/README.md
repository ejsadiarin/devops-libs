<!--2025-04-14-2346 (April 14, 2025 11:46:42 PM)-->

# To deploy

1. Save these manifests in separate files

2. Apply them in order:
```bash
kubectl apply -f namespace.yaml
kubectl apply -f postgres.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```
