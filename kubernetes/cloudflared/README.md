---
date: 2025-04-20T02:39
title: title
tags: 
    - Kubernetes
---
<!-- 2025-04-20-0239 (April 20, 2025 02:39:34 AM) -->

# K3s with Traefik and Cloudflared

- use `Traefik` as a Load Balancer/Ingress Controller/Reverse Proxy
- use `Cloudflared` to expose Kubernetes services (apps) to the internet
    - getting the "public IP" from `Cloudflared`
- deploy `whoami` and `uptime-kuma`

## Cloudflared Setup

[https://developers.cloudflare.com/cloudflare-one/tutorials/many-cfd-one-tunnel/](https://developers.cloudflare.com/cloudflare-one/tutorials/many-cfd-one-tunnel/)

- install `cloudflared`
```bash
# debian/ubuntu
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt update && sudo apt install cloudflared

# fedora/rhel/centos
sudo dnf config-manager addrepo --from-repofile=https://pkg.cloudflare.com/cloudflared-ascii.repo
sudo dnf install cloudflared
```

- create tunnel
```bash
cloudflared tunnel login
cloudflared tunnel create my-tunnel
```

- create Kubernetes secret resource for the credentials
```bash
kubectl create secret generic tunnel-credentials --from-file=credentials.json=.cloudflared/<credentials-id>.json
```

- get manifest file from [https://github.com/cloudflare/argo-tunnel-examples/blob/master/named-tunnel-k8s/cloudflared.yaml](https://github.com/cloudflare/argo-tunnel-examples/blob/master/named-tunnel-k8s/cloudflared.yaml)

- edit `replicas` to 1 (or leave 2 if you want, note that 25 is limit on free accounts)
- edit `secretName` (if not `tunnel-credentials`)
- edit cloudflare tag to `latest` or pin to stable version

- IMPORTANT: edit the ConfigMap `config.yaml` multi-line string to:
```yaml
tunnel: <your-tunnel-name>
ingress:
    - hostname: "*.example.com" # if using wildcard
      service: http://traefik.kube-system.svc.cluster.local:80
    - service: http_status:404
```

- apply manifest file 
```bash
kubectl apply -f cloudflared.yaml
```

- add CNAME record to tunnel (here we use * wildcard)
```bash
cloudflared tunnel route dns my-tunnel "*.example.com"
```

## Uptime Kuma

- ref: https://robododd.com/setup-uptime-kuma-on-kubernetes/

- copy manifest below and do `kubectl apply -f uptime-kuma.yaml`
    - if using helm chart then search that (maybe that's easier idk)
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: uptime
  labels:
    app: uptime
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: uptime
  template:
    metadata:
      labels:
        app: uptime
    spec:
      containers:
        - name: uptime
          image: louislam/uptime-kuma:latest
          ports:
            - containerPort: 3001
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          volumeMounts:
            - name: uptime-data
              mountPath: /app/data
          readinessProbe:
            httpGet:
              path: /
              port: 3001
            initialDelaySeconds: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: 3001
            initialDelaySeconds: 30
            periodSeconds: 10
      volumes:
        - name: uptime-data
          persistentVolumeClaim:
            claimName: uptime-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: uptime-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: uptime
  labels:
    app: uptime
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 3001
  selector:
    app: uptime
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: uptime-ingress
spec:
  ingressClassName: traefik
  rules:
    - host: uptime.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: uptime
                port:
                  number: 80
```

> [!NOTE]
> All Deployments must have a Service, as well as Ingress

- in this case, we also have a `PersistentVolumeClaim` (PVC) for stateful apps
    - `PersistentVolume` (PV) is automatically provisioned by the `local-path-provisioner` (k3s default storage class)


# Main Reference

- [From Zero to Hero: K3s, Traefik & Cloudflare Your Home Lab Powerhouse](https://www.youtube.com/watch?v=drmZjI6JWs8)
