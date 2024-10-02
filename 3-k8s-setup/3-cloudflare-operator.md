# Cloudflare Operator Setup
This operator is used to manage Cloudflare resources in a Kubernetes cluster.  It's a great way to manage DNS records and other Cloudflare resources in a declarative way.

## Light reading
https://github.com/adyanth/cloudflare-operator/blob/main/docs/getting-started.md


## Cloudflare setup

- API token - https://dash.cloudflare.com/profile/api-tokens
```
k8s-operator API token summary
This API token will affect the below accounts and zones, along with their respective permissions


Milagrofrost@gmail.com's Account - Cloudflare Tunnel:Edit, Account Settings:Read
frostbit.in - DNS:Edit
```

- API Key - https://dash.cloudflare.com/profile/api-tokens Use Global API Key located at the bottom of the page.

## Deploy the operator

- Deploy the operator using the following command.
```sh
kubectl apply -k https://github.com/adyanth/cloudflare-operator/config/default
```

## Deploy the ClusterTunnel

Follow the guide above to get your own config file, but her is mine for reference.


- For both token and Global key, you must encode them when creating the secret.  Here is an example of the secret creation.
```sh
echo -n "xxxCLOUDFLARE_API_KEYxxx" | base64
```

```yaml
# cloudflare-secrets.yaml
apiVersion: v1
data:
  CLOUDFLARE_API_KEY: BASE64_ENCODED_CLOUDFLARE_API_KEY # change this
  CLOUDFLARE_API_TOKEN: BASE64_ENCODED_CLOUDFLARE_API_TOKEN # change this
kind: Secret
metadata:
  name: cloudflare-secrets
  namespace: cloudflare-operator-system
type: Opaque
```

```yaml
# clustertunnel.yaml
apiVersion: networking.cfargotunnel.com/v1alpha1
kind: ClusterTunnel
metadata:
  labels:
    cfargotunnel.com/app: cloudflared
    cfargotunnel.com/domain: frostbit.in # CHANGETHIS
    cfargotunnel.com/is-cluster-tunnel: "false"
    cfargotunnel.com/name: k8s-cluster-tunnel
    cfargotunnel.com/tunnel: k8s-cluster-tunnel
  name: k8s-cluster-tunnel
spec:
  cloudflare:
    CLOUDFLARE_API_KEY: CLOUDFLARE_API_KEY # do not change this.  references the secret
    CLOUDFLARE_API_TOKEN: CLOUDFLARE_API_TOKEN # do not change this.  references the secret
    accountId: xxxaccountIdxxx # CHANGETHIS
    domain: frostbit.in # CHANGETHIS
    email: milagrofrost@gmail.com # CHANGETHIS
    secret: cloudflare-secrets
  existingTunnel: {}
  fallbackTarget: http_status:404
  image: cloudflare/cloudflared:2024.9.1 # currentlly the latest version
  newTunnel:
    name: k8s-cluster-tunnel
  noTlsVerify: false
  protocol: auto
  size: 2
```

- Apply the secrets and the clustertunnel
```sh
kubectl apply -f cloudflare-secrets.yaml
kubectl apply -f clustertunnel.yaml
```


- Check to make sure the tunnel pods are running
```sh
kubectl get pods -n cloudflare-operator-system
```

- Check to make sure the tunnel is up
```sh
kubectl get clustertunnel k3s-cluster-tunnel -n cloudflare-operator-system
```

## Potential issues

- Bad Token or Key encoding
- Imporper permissions on the Cloudflare token that you made
- Cilium CNI not ready for the tunnel deployment
- Incorrect domain or account ID
- You end up changing `k8s-cluster-tunnel` to something else.
  - make sure for every instance of `k8s-cluster-tunnel` you change it to the same name of your choosing.