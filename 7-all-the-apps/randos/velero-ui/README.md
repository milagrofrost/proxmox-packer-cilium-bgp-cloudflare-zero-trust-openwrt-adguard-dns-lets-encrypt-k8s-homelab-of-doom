# Velero-UI

I use velero to back up my k8s cluster.  You can ge the status of your velero backups usign the CLI, but I wanted a UI to see the status of my backups.

## Installation

- RTFM - https://vui.seriohub.com/docs/getting-started/helm-installation
- Change the override.yaml file to match your environment
- Make a security token key and change the bogus value for securityTokenKey in the override.yaml file
  - `openssl rand -hex 32`

```powershell
helm repo add seriohub-velero https://seriohub.github.io/velero-helm/
helm search repo seriohub-velero
kubectl create ns velero-ui
helm install -f values-override.yaml vui seriohub-velero/vui -n velero-ui
```

- By default the UI is not exposed.  I'm exposing it using the frontend stack that I have in place.  I'm using the same domain as the rest of my apps.
- update the values in frontend.yaml to match your environment

```powershell
kubectl apply -f frontend.yaml
```