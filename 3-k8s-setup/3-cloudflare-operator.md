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

Follow the guide above to get your own config file, but here is mine for reference.


- Create the secret for the Cloudflare API Key and Token
```sh
kubectl -n cloudflare-operator-system create secret generic cloudflare-secrets --from-literal CLOUDFLARE_API_TOKEN=<api-token> --from-literal CLOUDFLARE_API_KEY=<api-key>
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
kubectl apply -f clustertunnel.yaml
```


- Check to make sure the tunnel pods are running
```sh
kubectl get pods -n cloudflare-operator-system
```

- Check to make sure the tunnel is up
```sh
kubectl get clustertunnel k8s-cluster-tunnel -n cloudflare-operator-system
```

## Potential issues

- Bad Token or Key encoding
- Imporper permissions on the Cloudflare token that you made
- Cilium CNI not ready for the tunnel deployment
- Incorrect domain or account ID
- You end up changing `k8s-cluster-tunnel` to something else.
  - make sure for every instance of `k8s-cluster-tunnel` you change it to the same name of your choosing.
- If you k8s nodes are failing to terminate the tunnel pods after each configuration update, you will have stale tunnels with old configurations running.  This will cause the new configuration to not work.  For me, I forgot to disable Ubuntu AppArmor on the nodes.  This was causing the pods to not terminate properly.  I disabled AppArmor and the pods terminated properly.  I then updated the configuration and the new tunnel was created with the new configuration.