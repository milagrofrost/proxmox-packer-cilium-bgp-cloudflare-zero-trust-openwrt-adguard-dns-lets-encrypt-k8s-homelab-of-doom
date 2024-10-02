# OpenWRT with k8s and cilium
## Use Case
- OpenWRT can be used with a Kubernetes cluster for service meshing.
- Cilium creates BGP peering with OpenWRT to advertise new k8s service IPs.
- OpenWRT can then route traffic to the correct service IP.
- OpenWRT can also run AdGuardHome for DNS filtering and more importantly DNS rewriting for k8s service IPs.
- Internal DNS resolution can be done using AdGuardHome DNS rewriting.

## Specific Setup (deviations possible, but this is what I did)
- OpenWRT running on a Raspberry Pi 4.
- OpenWRT acting as the main home router.
- OpenWRT router with AdGuardHome installed.
- OpenWRT running bird for BGP peering with Cilium.
- LAN network is using the internal NIC on the Raspberry Pi.
- WAN network is using the USB NIC on the Raspberry Pi.
- All home devices use the OpenWRT router (adguardhome) as the DNS server.
- My internal network name is `br-lan` on OpenWRT.

## OpenWRT Setup
- Install AdGuardHome from OpenWRT package manager.
  - AdguardHome will be aviailable at `http://<router-ip>:8080`
  - Set up AdGuardHome to your personal preferences.  Not needed for k8s setup.
- Install bird1-ipv4 from OpenWRT package manager.
- Install bird1cl-ipv4 from OpenWRT package manager.

## Bird Configuration
- SSH into the OpenWRT router.
- vi /etc/bird4.conf
```conf
router id 10.10.101.1;

protocol kernel {
  persist;
  scan time 20;
  import all;
  export all;
}

protocol device {
  scan time 10;
}

protocol direct {
  interface "br-lan";
}

protocol bgp k8sm1 {
  local as 65000;
  neighbor 10.10.101.241 as 65001;
  import all;
}

protocol bgp k8sw1 {
  local as 65000;
  neighbor 10.10.101.242 as 65001;
  import all;
}

protocol bgp k8sw2 {
  local as 65000;
  neighbor 10.10.101.243 as 65001;
  import all;
}
```
### Semi-Optional Customizations
- Change the `router id` to the IP of the OpenWRT router.
- Change the `neighbor` IPs to the IPs of the k8s nodes. 
- Change the `local as` to a unique AS number for the router itself.
- Change the `neighbor as` to a unique AS number for the k8s nodes.
- Change the `interface` to the internal network name of the OpenWRT router.

- Restart the bird service.
  `service bird4 restart`

## BIRD/BGP Troubleshooting
- Checking bird configuration
`bird4 -c /etc/bird4.conf`
- Checking bird status
`ps | grep bird`
- Checking bird peers
`birdcl4 show protocols`
- Checking bird routes
`birdcl4 show route all`

## AdGuard Troubleshooting
Where the external-dns k8s provider makes it's DNS rewrites
http://ROUTER_IP:8080/#custom_rules