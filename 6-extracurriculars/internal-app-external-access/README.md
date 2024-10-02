# Internal App External Access

## Prerequisites

- You've already followed the setup instructions in the previous sections.

## Problem

- The Hubble UI is only accessible from inside the cluster.  This is because the Hubble UI service is a ClusterIP service.  To access the Hubble UI from outside the cluster, we need to expose the service to the outside world.  I'm sure there might be better way than what I'm about to show you but this is how I did it.  

## Additional problems

- Some containers or other services may by default serve their app over HTTPS.  I want to set up a Gateway that will front the these SSL/HTTPS enabled apps and provide HTTPS access to the app with a publicly trusted certificate (rather than using the self signed cert that comes with most HTTPS-apps.).  
- The issue is that Cilium Gateway does not support HTTPS backends `WITH` SSL termination (yet).  So for now, we need to set up an Nginx reverse proxy to handle the HTTPS traffic and forward it to the HTTPS app service.
- This can not only work for a k8s hosted HTTPS-app, but also for any other web endpoint on your local network that you want to expose to the internet.

## Setup

- I've create a helm chart that will deploy a collection of resources:
  - Deployment/pod
    -  Nginx reverse proxy that will forward traffic to the HTTPS app service.
  - ConfigMap
    - Nginx configuration file that will be used by the Nginx reverse proxy.
  - Service
    - LoadBalancer service that will expose the Nginx reverse proxy
  - Gateway
    - Cilium Gateway that will route traffic to the Nginx reverse proxy service.  
  - HTTPRoute
    - Cilium HTTPRoute that will route traffic to the Nginx reverse proxy service.
  - TunnelBinding
    - Cloudflare TunnelBinding that will bind the Gateway to a Cloudflare Tunnel for external access.

Client -> Cloudflare Tunnel -> Cilium Gateway Service -> Cilium HTTPRoute/Gateway -> Nginx Service -> NGINX Pod -> App Pod Service -> App Pod

## Assumptions

- You are deploying all of this in the `default` namespace.
- You are creating a subdomain for every service you expose.  For example, if you are exposing the Hubble UI, you would create a subdomain like `hubble-ui.example.com`.

## Usage

- Make sure to update the `values.yaml` file with your own values.  The `values.yaml` file is located in the `custom-ingresses` folder.
- While in the folder of this README, Run the following command to deploy the helm chart:

```sh
helm install custom-ingresses ./custom-ingresses
```