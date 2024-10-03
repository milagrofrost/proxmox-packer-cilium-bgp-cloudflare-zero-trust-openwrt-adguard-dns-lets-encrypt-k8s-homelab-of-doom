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
- Apply the pod and service with the following command:
  ```sh
  kubectl apply -f k8-files/1-pod.yaml
  ```
- Check the status of the pod and service with the following command:
  ```sh
    kubectl get pods
    kubectl get svc
  ```
- If you are using BGP service advertisement, you can check the status of the BGP service advertisement with the commands detailed in the 3-k8s-setup/2-cilium-bgp.md file.
- You should be able to access the pod from within the cluster by using the `EXTERNAL-IP` of the service.  You can get the `EXTERNAL-IP` of the service with the following command:
  ```sh
  kubectl get svc
  ```
  - The `EXTERNAL-IP` should be the IP address of the pod.  You can test access to the pod by using the `EXTERNAL-IP` and the port number of the service.  For example, if the `EXTERNAL-IP` is `10.10.100.0` and the service port number of the service is `5800`, you can access the pod by going to `http://10.10.100.0:5800` in a web browser.

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

- Apply the Gateway and HTTPRoute with the following command:
  ```sh
  kubectl apply -f k8-files/2-ingress.yaml
  ```
- Check the status of the Gateway and HTTPRoute with the following command:
  ```sh
    kubectl get gateway gateway
    kubectl get gateway gateway -o yaml
    kubectl get httproute 
    kubeclt get httproute route -o yaml
  ```
- At the end of the Gateway and HTTPRoute resource yaml definition, you will see a status section.  This will tell you if the Gateway and HTTPRoute are working properly and the confiugrations have been accepeted by the Cilium Gateway API / Envoy Proxy.
- This should also kick off the cert-generator certificate order and application.  You can check the status of the cert-generator with the following command:
  ```sh
    kubectl get certificate,certificaterequest,order -A
  ```

- If you are using AdGuard Home for internal DNS resolution, you can check to see if the name has been added to the DNS re-write list in the AdGuard Home UI.
- If you using Adguard as your internal DNS resolver on the machine where you are testing sites on, you can attempt to hit the site by the domain name you used in the Gateway and HTTPRoute resource definition.  For example, if you used `home1.forstbit.in` as the domain name in the Gateway and HTTPRoute resource definition, you can attempt to hit the site by going to `http://home1.forstbit.in` in a web browser.   Hopefully it will resolve.
  
- The new gateway also makes another service with an `EXTERNAL-IP`.  This is the service that allows you to hit your app at the Gateway API.  You can get the `EXTERNAL-IP` of the service with the following command:
  ```sh
  kubectl get svc cilium-gateway-gateway
  ```
  - This should be listening on port 80 and 443 for HTTP and HTTPS traffic, respectively.
  - The `EXTERNAL-IP` should be the IP address of the Gateway.  You can test access to the pod by using the `EXTERNAL-IP` and the port number of the service.  For example, if the `EXTERNAL-IP` is `10.10.100.1` and the service port number of the service is `80`, you can access the pod by going to `http://10.10.100.1` in a web browser.
  - You cannot hit the gateway over HTTPS with an IP address.  You must use a domain name that is associated with the Gateway.  This is because the Gateway is using SNI to route traffic to the correct HTTPRoute.  If you try to hit the Gateway over HTTPS with an IP address, you will get a connection reset error.  
  - You can use a curl command to work around this if you need to test with out proper DNS resolution.  For example:
    ```sh
    curl -k https://home1.forstbit.in --resolve home1.forstbit.in:443:10.10.100.1 -v
    ```

### Cloudflare Tunnel
- File `3-tunnel.yaml` has a TunnelBinding resource defined in it.
  - The TunnelBinding is a Cloudflare TunnelBinding that will bind the Gateway to a Cloudflare Tunnel for external access.
  - Successful deployment of the TunnelBinding will indicate:
    - The Cloudflare Tunnel is working properly
    - Access to the pod from the internet is working properly

- Apply the TunnelBinding with the following command:
- Check the status of the TunnelBinding with the following command:
  ```sh
  kubectl apply -f k8-files/3-tunnel.yaml
  kubectl get tunnelbinding
  ```
- Best indicator that things are working is to check the Cloudflare dashboard and see if the tunnel is up and running in Zero Trust.  Also check for a new DNS record in the Cloudflare DNS dashboard.
  ```sh
  kubectl get tunnelbinding
  ```
- In order the test this site through CLoudflare you can try on you mobile device while off the Wifi, use a VPN or don't use Adguard as your DNS resolver.  
- With that in mind, visit the site https://home1.frostbit.in in a web browser.  You should see the simple HTML page that is being served by the pod.