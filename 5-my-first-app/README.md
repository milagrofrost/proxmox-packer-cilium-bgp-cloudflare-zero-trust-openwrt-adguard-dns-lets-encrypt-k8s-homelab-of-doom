# My First app using Cilium, BGP service advertisement, and Cloudflare Tunnel

This will be a test of how well I documented the setup and/or your ability to follow instructions.  LOL!!!  Software version changes and hardware differences be damned!  Let's see if we can get this to work!

## Definitions

- There are 3 files in the k8-files folder that will be used to deploy the app.  We will work through each one.  Validate and troubleshoot as needed.

### Pod and Service

- File `1-pod.yaml` has two resources defined in it.  A pod and a service. 
  - The pod is running a simple web/nginx server that will serve a simple HTML page.
    - Successful deployment of the pod will indicate the Cilium CNI is working properly (not a thorough test, but a good start).
  - The service is a ClusterIP service that will expose the pod to the cluster.
    - Deploying this service will allow us to test the pod from within the cluster, of source
    - Successful deployment of the pod service will indicate:
      - The LB Pool is working properly
      - BGP service advertisement is working properly
      - Access to the pod from the cluster is working properly

### Gateway and HTTPRoute

- File `2-ingress.yaml` has two resources defined in it.  A Gateway and an HTTPRoute.
  - The Gateway is a Cilium Gateway that will route traffic to the HTTPRoute.
  - The HTTPRoute is a Cilium HTTPRoute that will route traffic to the service.
  - Successful deployment of the Gateway and HTTPRoute will indicate:
    - The cert-generator is working properly
    - The external-dns is working properly
    - Access to the pod through the Gateway is working properly
    - Internal DNS resolution is working properly
  - I know I called it an ingress, and it's not really an Ingress in the context of k8s.  It's a Gateway and HTTPRoute.  But it's our ingress endpoint from an networking perspective.  Stop twitching that eye.

### Cloudflare Tunnel
- File `3-tunnel.yaml` has a TunnelBinding resource defined in it.
  - The TunnelBinding is a Cloudflare TunnelBinding that will bind the Gateway to a Cloudflare Tunnel for external access.
  - Successful deployment of the TunnelBinding will indicate:
    - The Cloudflare Tunnel is working properly
    - Access to the pod from the internet is working properly