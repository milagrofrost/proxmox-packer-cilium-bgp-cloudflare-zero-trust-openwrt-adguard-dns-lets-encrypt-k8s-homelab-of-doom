# What it do

- I've found out that k8s gateway-api does not do HTTPS to HTTPS backends.  This is a problem because I want to use HTTPS for all my services with a public trusted cert.  You can have non-SSL/non-HTTPS backends all day with the gateway-api, but as soon as that backend is HTTPS, you're out of luck.  
- I've found a workaround for this by injecting an nginx pod between the gateway and HTTPS service.
- The nginx pod will take the HTTPS service and make a non-SSL/non-HTTPS connection at it's front end for the gateway-api to connect to.
- Here's the flow:
  - Gateway-api (SSL/HTTPS Frontend) -> Nginx (non-SSL/non-HTTPS Frontend) -> HTTPS service
- On top of that, I like to create public endpoints for all the other home services that I have running on my network.  This is a good way to expose services to the internet without having to open up ports on your router.
- Router web UIs, 3d printer web UIs, etc.  I like to have them all behind a public endpoint with a public trusted cert.
- On the apps where they come deployed with a self-signed cert, I will not deploy the gateway nor the tunnelbinding resources.  This helm chart will create the necessary resources for the gateway and tunnelbinding resources to help complete the flow.

# Prerequisites

- Helm
- Any service that is either HTTP or HTTPS.  This will be the service that you want to expose to the internet.
- Assuming you have already setup (as described in previous sections):
  - the Cloudflare Operator and have a domain that you want to use for the service.
  - The cert-manager and have a ClusterIssuer setup with Cloudflare as the DNS01 solver.
  - The cilium CNI and gateway-api setup on your cluster.

# Setup Instructions

- Edit the `values.yaml` file to match your domain and service that you want to expose.
- Attributes you need to define
```yaml
domain: frostbit.in
tunnel_name: k8s-cluster-tunnel
gateways:
  router:
    name: router
    endpoint: 10.10.101.1
    port: 80
    backend_protocol: http
    namespace: default
  adguard:
    name: adguard
    endpoint: 10.10.101.1
    ...............................
```
  - `domain` - This will be the name the domain that you want to expose your service on.  This will be the domain that you will use to access your service from the internet.
  - `tunnel_name` - This is the name of the ClusterTunnel resource that you created in the Cloudflare Operator setup.
  - `router` - This is just a unique name for the service that you want to expose.  You can have multiple services that you want to expose.  Just add another entry in the `gateways` section.
    - `name` - This is the DNS name that you want to use for the service.  This will be the name that you use to access the service from the internet.
    - `endpoint` - This is the IP address OR dns name (can be a k8s FQDN) of the service that you want to expose.
    - `port` - This is the port that the service is running on.
    - `backend_protocol` - This is the protocol that the service is running on.  This can be either `http` or `https`.
    - `namespace` - This is the namespace where you want to deploy the gateway and tunnelbinding resources.

## Resources Created

```
❯   kubectl get deployment,gateway,httproute,service,configmap,tunnelbinding -n unifi -l app=external-unifi -o wide
>> 
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
deployment.apps/external-unifi   1/1     1            1           61m   nginx        nginx:latest   app=external-unifi

NAME                                              CLASS    ADDRESS        PROGRAMMED   AGE
gateway.gateway.networking.k8s.io/gateway-unifi   cilium   10.10.100.41   True         61m

NAME                                              HOSTNAMES   AGE
httproute.gateway.networking.k8s.io/route-unifi               61m

NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)          AGE   SELECTOR
service/external-unifi   LoadBalancer   10.104.183.208   10.10.100.35   8443:31650/TCP   61m   app=external-unifi

NAME                              DATA   AGE
configmap/external-unifi-config   1      61m

NAME                                                     FQDNS
tunnelbinding.networking.cfargotunnel.com/tunnel-unifi   unifi.frostbit.in
```

- And take a peek at the `example-deployment-from-this-helm` folder for an example deployment that you can use reference.

## Caveats

- If you install this helm chart and later update the values for an existing deployment you'll need to delete the nginx pod to get the new configuration.  The nginx pod is setup to not restart on configuration changes.  You can possibly have it restart on configuration changes by adding this annotation in the deployment metadata (not sure what the value should be):
```yaml
annotations:
        checksum/config: ......................
```
