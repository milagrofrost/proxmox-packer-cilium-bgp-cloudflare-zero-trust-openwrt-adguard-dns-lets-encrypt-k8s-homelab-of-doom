resource "proxmox_vm_qemu" "k8s_master" {
    name                      = "k8s-m1"
    boot                      = "order=virtio0"
    clone                     = var.template_name
    full_clone	              = true
    target_node               = var.pve_node_name
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "kvm64"
    agent                     = 1
    sockets                   = 1
    cores                     = 4
    memory                    = 4096
    ci_wait                   = 0
    ipconfig0                 = "ip=${var.k8s_master_ip}${var.subnet_mask},gw=${var.subnet_gw}"

    network {
        bridge    = "vmbr0"
        model     = "e1000"
        firewall  = false
        link_down = false
    }
}

resource "proxmox_vm_qemu" "k8s_workers" {
    count                     = length(var.k8s_worker_ips)
    name                      = "k8s-w${count.index+1}"
    boot                      = "order=virtio0"
    clone                     = var.template_name
    target_node               = var.pve_node_name
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 1
    sockets                   = 1
    cores                     = 4
    memory                    = 6144
    os_type                   = "cloud-init"
    ipconfig0                 = "ip=${element(var.k8s_worker_ips, count.index)}${var.subnet_mask},gw=${var.subnet_gw}"

    network {
        bridge    = "vmbr0"
        model     = "virtio"
        firewall  = false
        link_down = false
    }

}

