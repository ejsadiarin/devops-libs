<!--2025-05-02 05:15-->

# Setting Resource Limits for Longhorn

Longhorn can be resource-intensive. Consider limiting its resources.

This patch command below only adjusts resources for the `longhorn-manager` deployment

```bash
kubectl -n longhorn-system patch deployment longhorn-manager --patch '{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "longhorn-manager",
            "resources": {
              "limits": {
                "cpu": "500m",
                "memory": "512Mi"
              },
              "requests": {
                "cpu": "100m",
                "memory": "256Mi"
              }
            }
          }
        ]
      }
    }
  }
}'
```

You can similarly adjust resources for other Longhorn components.
