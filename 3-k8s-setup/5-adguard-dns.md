# AdGuardHome external-dns provider

This will create internal DNS names (via DNS rewrites) for your k8s services.  This is useful for internal DNS resolution of your services when you are on the local network.

## Prerequisites

- A Kubernetes cluster OBVIOUSLY
- AdGuardHome installed and running somewhere on your network.  In this case, it's running on OpenWRT on a Raspberry Pi 4.
  
## Setup Instructions

- RTFM: https://github.com/muhlba91/external-dns-provider-adguard
- Add the helm repo for the adguard external-dns provider
  ```sh
  helm repo add bitnami https://charts.bitnami.com/bitnami
  ```
- Create a secret with your AdGuardHome URL, user, and password
  ```sh
  kubectl create secret generic adguard-configuration --from-literal=url='http://10.10.101.1:8080' --from-literal=user='root' --from-literal=password='password'
    ```
- create the helm values file
```yaml
cat <<EOF > external-dns-adguard-values.yaml
provider: webhook

extraArgs:
webhook-provider-url: http://localhost:8888

sidecars:
- name: adguard-webhook
    image: ghcr.io/muhlba91/external-dns-provider-adguard
    ports:
    - containerPort: 8888
        name: http
    livenessProbe:
    httpGet:
        path: /healthz
        port: http
    initialDelaySeconds: 10
    timeoutSeconds: 5
    readinessProbe:
    httpGet:
        path: /healthz
        port: http
    initialDelaySeconds: 10
    timeoutSeconds: 5
    env:
    - name: LOG_LEVEL
        value: debug
    - name: ADGUARD_URL
        valueFrom:
        secretKeyRef:
            name: adguard-configuration
            key: url
    - name: ADGUARD_USER
        valueFrom:
        secretKeyRef:
            name: adguard-configuration
            key: user
    - name: ADGUARD_PASSWORD
        valueFrom:
        secretKeyRef:
            name: adguard-configuration
            key: password
    - name: SERVER_HOST
        value: "0.0.0.0" 
    - name: DRY_RUN
        value: "false"  
EOF
```

- install external-dns with helm

```sh
    helm install external-dns-adguard bitnami/external-dns -f external-dns-adguard-values.yaml
```

- check the pods to make sure it's running

```sh
    kubectl --namespace=default get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=external-dns-adguard"
```