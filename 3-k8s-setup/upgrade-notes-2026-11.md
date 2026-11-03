# Upgrade notes: Kubernetes 1.30 to 1.36 (November 2026)

Versions after the upgrade: Kubernetes 1.36.6, Cilium 1.20.4, Gateway API 1.6.3 (experimental channel),
cert-manager 1.21.3, Velero 1.18.4 with GCP plugin 1.14.4, cloudflare-operator 0.14.0, cloudflared 2026.10.7.

## Order used
Kubernetes and Cilium move one minor version at a time, and each Cilium version only supports certain Kubernetes versions:

| Cilium | Gateway API | Kubernetes after it |
|---|---|---|
| 1.17 | 1.2.0 | 1.30, 1.31 |
| 1.18 | 1.3.0 | 1.32, 1.33 |
| 1.19 | 1.4.1 | 1.34, 1.35 |
| 1.20 | 1.6.3 | 1.36 |

## Things that bite on this cluster
- **kubeadm 1.32 and later install kube-proxy by default.** This cluster uses Cilium instead. `kubeadm-config` now has `proxy.disabled: true`, and upgrades use `kubeadm upgrade apply --skip-phases addon/kube-proxy`. If it comes back, delete the DaemonSet and ConfigMap, then remove its iptables rules on each node.
- **Gateway API 1.2 changes the GatewayClass status format.** `helm upgrade` for Cilium fails until the old field is removed: `kubectl patch gatewayclass cilium --subresource=status --type=json -p '[{"op":"remove","path":"/status/supportedFeatures"}]'`.
- **Images that use `latest` upgrade themselves on restart or when moved to another node.** Apps are pinned to digests for that reason. Change the digest on purpose to upgrade.
- **Some old images have gone from their registries:** `gcr.io/kubebuilder/kube-rbac-proxy` and the tag-based `bitnami/external-dns`. external-dns currently runs `bitnamilegacy/external-dns:0.15.0-debian-12-r2`, which gets no more updates.
- **cloudflare-operator before 0.13 ignores changes to `spec.image`.** Upgrade the operator before changing the `cloudflared` version.
- **Home Assistant keeps its history in SQLite on NFS.** It has been corrupted repeatedly. Consider moving it to MariaDB.

## Removed
Argo CD, `guestbook` and Kubernetes Dashboard. `kube.frostbit.in` now serves Headlamp (chart 0.46.0) from the `kubernetes-dashboard` namespace.
Sign in with a token: `kubectl create token headlamp -n kubernetes-dashboard`.

## Not done yet
`1-packer` now targets Kubernetes 1.36, but template VM 100 has not been rebuilt, so it still builds 1.30 nodes.