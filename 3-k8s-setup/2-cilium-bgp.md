# Cilium BGP Setup
This guide will walk you through setting up BGP peering between Cilium and a router running BIRD.  This is a great way to have your Kubernetes cluster advertise its services to the rest of your network.

## Prerequisites
- A Kubernetes cluster running Cilium
- A router running BIRD
- Router is setup with BGP peering configurations that comply with Cilium's BGP configurations
- Familiarity with BGP

## Setup Instructions
BGP advertisemnt resources are created in the `cilium` namespace.  This is where you will define the advertisements that Cilium will send to the router. `matchExpressions: - key: somekey  operator: NotIn values:  -never-used-value` ensures that all services will be advertised to the router.  

Dont take my word for it, read up on it!!  https://docs.cilium.io/en/stable/network/bgp-toc/

```yaml
# kubectl get ciliumbgpadvertisements.cilium.io -o yaml
# some values will need to be changed to match your environment

apiVersion: cilium.io/v2alpha1
kind: CiliumBGPAdvertisement
metadata:
  labels:
    advertise: bgp
  name: bgp-advertisements
spec:
  advertisements:
  - advertisementType: Service
    selector:
      matchExpressions:
      - key: somekey  # this is not a placeholder, this is legit
        operator: NotIn
        values:
        - never-used-value
    service:
      addresses:
      - ExternalIP
      - LoadBalancerIP
```

BGP cluster configs are where you 1-to-1 map the Cilium BGP peer to the router BGP peer.  This is where you define the ASN, peer address, and peer ASN.  The `nodeSelector` is used to select which nodes will participate in the BGP peering.  In this case, only Linux nodes will participate.  This policy applies to all nodes in the cluster.
```yaml
# kubectl get ciliumbgpclusterconfigs.cilium.io cilium-bgp -o yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPClusterConfig
metadata:
  name: cilium-bgp
spec:
  bgpInstances:
  - localASN: 65011
    name: cluster
    peers:
    - name: peer
      peerASN: 65010
      peerAddress: 10.10.101.1
      peerConfigRef:
        group: cilium.io
        kind: CiliumBGPPeerConfig
        name: cilium-peer  # linked to the CiliumBGPPeerConfig object below
  nodeSelector:
    matchLabels:
      kubernetes.io/os: linux
```

The BGP peer config is the last part to enabling BGP peering and advertisements.  
```yaml
# kubectl get ciliumbgppeerconfigs.cilium.io cilium-peer -o yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPPeerConfig
metadata:
  name: cilium-peer
spec:
  ebgpMultihop: 1
  families:
  - advertisements:
      matchLabels:
        advertise: bgp # linked to the CiliumBGPAdvertisement object above
    afi: ipv4
    safi: unicast
  gracefulRestart:
    enabled: true
    restartTimeSeconds: 15
```

## Troubleshooting
- Find a cilium pod to query
`kubectl get pods -n kube-system -l k8s-app=cilium`
- Check BGP Routes
`kubectl exec -n kube-system cilium-4sfmd -- cilium bgp routes -D`
- Check BGP Peers
`kubectl exec -n kube-system cilium-4sfmd -- cilium bgp peers`
- Check to see if k8s nodes are participating in BGP (run on a k8s node)
- Should see bi-directional traffic
`sudo tcpdump -an -i YOUR_PRIMARY_INTERFACE port 179`

## Confirming BGP Peering

- On the router, you should see the BGP peer established
  - On my OpenWRT router and bird4 setup, I can see the peer established with the following command:
  ```
  root@OpenWrt:~# birdcl4 show protocols
  BIRD 1.6.8 ready.
  name     proto    table    state  since       info
  kernel1  Kernel   master   up     21:05:02
  device1  Device   master   up     21:05:02
  direct1  Direct   master   up     21:05:02
  k8sm1    BGP      master   up     21:05:14    Established
  k8sw1    BGP      master   up     21:05:13    Established
  k8sw2    BGP      master   up     21:05:14    Established
  k8sm1temp BGP      master   up     04:56:46    Established
  k8sw1temp BGP      master   up     04:56:51    Established
  k8sw2temp BGP      master   up     04:56:49    Established
  ```
  - And see the routes being advertised ( this is after you create some services in k8s )
  ```
  root@OpenWrt:~# birdcl4 show route
  BIRD 1.6.8 ready.
  10.10.200.58/32    via 10.10.101.241 on br-lan [k8sm1 21:05:14] * (100) [AS65001i]
                    via 10.10.101.242 on br-lan [k8sw1 21:05:13] (100) [AS65001i]
                    via 10.10.101.243 on br-lan [k8sw2 21:05:14] (100) [AS65001i]
  10.10.200.59/32    via 10.10.101.241 on br-lan [k8sm1 21:05:14] * (100) [AS65001i]
                    via 10.10.101.242 on br-lan [k8sw1 21:05:13] (100) [AS65001i]
                    via 10.10.101.243 on br-lan [k8sw2 21:05:14] (100) [AS65001i]
  10.10.200.56/32    via 10.10.101.241 on br-lan [k8sm1 21:05:14] * (100) [AS65001i]
                    via 10.10.101.242 on br-lan [k8sw1 21:05:13] (100) [AS65001i]
                    via 10.10.101.243 on br-lan [k8sw2 21:05:14] (100) [AS65001i]
  .............AND MORE!!!!!!................
  ```