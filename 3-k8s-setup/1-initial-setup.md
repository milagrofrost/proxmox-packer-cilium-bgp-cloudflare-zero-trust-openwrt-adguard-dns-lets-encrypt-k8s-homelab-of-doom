# Kubernetes Setup with Cilium

## Prerequisites
- Tested on `kubectl` 1.30.5
- This is an abridged setup guide, but get familiar with k8s and cilium documentation as well.  For when things go wrong....

## Setup Instructions

### On the Master Node

1. **Install Cilium CLI:**
    ```sh
    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
    ```

2. **Initialize Kubernetes:**
    - Change `--apiserver-advertise-address 10.10.101.251` to your designated master IP address.
    - Change `--pod-network-cidr=10.1.1.0/24` to a different CIDR if it overlaps with an existing local network.
    ```sh
    sudo kubeadm init --apiserver-advertise-address 10.10.101.251 --skip-phases=addon/kube-proxy --pod-network-cidr=10.1.1.0/24
    ```
    - Copy the `kubeadm join` command that's outputted at the end of this `kubeadm init` command.

3. **Configure kubectl:**
    ```sh
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```

### On All Worker Nodes

X. **Join the Cluster:**
    - Run the `kubeadm join` command that was outputted from the master. Must run as `sudo` or `root`
    - Example:
    ```sh
    sudo kubeadm join 10.10.101.251:6443 --token xxxxx.xxxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```


### Back to Master

4. **Verify Nodes:**
    ```sh
    kubectl get nodes
    # Nodes will not be ready yet.
    ```

5. **Check System Pods:**
    ```sh
    kubectl get pods -n kube-system
    # Make sure all pods are settled and running.
    ```

6. **Install Experimental Gateway API:**
    - This is needed for the Cilium Gateway API to work.  Installing version `1.2.0-rc2` for support of applying labels to services created by the Gateway API.
    ```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
    ```

6. **Install Cilium with Helm:**
    - Change `--set k8sServiceHost="10.10.101.251"`  to your Master ip
    - At this time of documentation cilium version `1.16.1` is what was latest and tested in this setup
    ```sh
    helm repo add cilium https://helm.cilium.io/
    helm install cilium cilium/cilium --version 1.16.1 --namespace kube-system \
        --set k8sServiceHost="10.10.101.251" \
        --set k8sServicePort="6443" \
        --set kubeProxyReplacement=true \
        --set bgpControlPlane.enabled=true \
        --set bgpControlPlane.configMap=configMapName \
        --set debug.enabled=true \
        --set gatewayAPI.enabled=true \
        --set hubble.relay.enabled=true \
        --set hubble.ui.enabled=true
    ```

7. **Verify Cilium Deployment:**
    ```sh
    kubectl get pods -n kube-system
    # Make sure all Cilium pods start up. Give it +/- ten minutes.
    ```

    ```sh
    cilium status
    # This will give you the status of the cilium deployment
    ```

8. **Verify Nodes Again:**
    ```sh
    kubectl get nodes
    # Nodes should be ready now after Cilium is fully deployed.
    ```

9. **Apply Load Balancer IP Pool**
   - Ensure that the `cidr` is not overlapping with any existing networks
```yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumLoadBalancerIPPool
metadata:
  labels:
    service-type: internal
  name: pool
spec:
  blocks:
  - cidr: 10.10.100.0/24
```

### Optional

1. **Enable Metrics:**
    - This is optional, but if you want to enable metrics, you can do so with the following command:
    ```sh
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    ```
    - I had certificate issues with the metrics server, so I had to edit the `metrics-server` deployment and add the following to the `command` section:
    ```sh
    kubectl edit deployment metrics-server -n kube-system
    ```
    - added `- --kubelet-insecure-tls` to the `args` section of the `metrics-server` container
    ```yaml
    spec:
    containers:
    - name: metrics-server
        args:
        - --cert-dir=/tmp
        - --secure-port=10250
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
    ```


### Troubleshooting

- If nodes are still not ready after some time, make sure the configuration commands that packer runs  (at the bottom of `1-packer/build.pkr.hcl`) have actually configured the desired settings
- Improper network configurations like a lack of ipforwarding may cause issues with the cilium CNI


