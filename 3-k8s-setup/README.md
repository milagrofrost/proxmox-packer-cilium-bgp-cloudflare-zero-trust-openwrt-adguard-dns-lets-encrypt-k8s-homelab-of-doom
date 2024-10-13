# Setting up k8s

This is a guide to setting up a k8s cluster with some of the tools that I've used to make my life easier.  I've broken it down into the following sections:

- [1. Initial Setup](1-initial-setup.md)
  - Initial setup of the k8s cluster.
- [2. Enable Cilium BGP](2-cilium-bgp.md) 
  - Setting up BGP peering between Cilium and a router running BIRD.
- [3. Cloudflare Operator](3-cloudflare-operator.md)
  - This operator is used to manage Cloudflare tunnel resources in a Kubernetes cluster for external access to services.
- [4. Cert-Manager](4-cert-manager.md)
  - Setting up the cert-manager to issue certs across all namespaces.
- [5. AdGuard DNS](5-adguard-dns.md) 
    - Setting up AdGuard DNS for automatic DNS record creation on AdGuard Home DNS service for internal DNS resolution.