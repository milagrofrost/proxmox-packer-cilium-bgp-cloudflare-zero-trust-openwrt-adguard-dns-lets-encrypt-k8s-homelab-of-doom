############################################
#                                          #
#        packer provisioner block          #
#                                          #
# ##########################################
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

############################################
#                                          #
#      variable statement blocks           #
#                                          #
############################################

##### vvvvvvvvvvvvvvvvv Required Variables vvvvvvvvvvvvvvvvv #####

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_username" {
    type    = string
}

variable "proxmox_password" {
    type      = string
    sensitive = true
}

variable "proxmox_node" {
  type    = string
}

variable "ssh_pass_hash" {
  sensitive = true
  type      = string
}

##### ^^^^^^^^^^^^^^^ Required Variables ^^^^^^^^^^^^^^^ #####



variable "ssh_user" {
  default = "packer"
  type    = string
}

variable "ssh_pass" {
  default   = "packer"
  sensitive = true
}

variable "kube_version" {
  default   = "1.30"
  sensitive = true
}

variable "vm_name" {
  default = "ubuntu-2404lts-k8s"
  type    = string
}

variable "iso_checksum" {
  default = "e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
  # pulled from https://releases.ubuntu.com/24.04.1/SHA256SUMS
  type    = string
}

variable "iso_url" {
  default = "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
  type    = string
}

variable "iso_storage_pool" {
  default = "local"
  type    = string
}

variable "unmount_iso" {
  default = true
  type    = bool
}

variable "qemu_agent" {
  default = true
  type    = bool
}

variable "scsi_controller" {
  default = "virtio-scsi-pci"
  type    = string
}

variable "disks" {
  default = [{
    disk_size    = "100G"
    storage_pool = "local-lvm"
    type         = "virtio"
  }]
}

variable "memory" {
  default = "2048"
  type    = string
}

variable "cores" {
  default = "1"
  type    = string
}

variable "network_adapters" {
  default = [{
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }]
}

variable "cloud_init" {
  default = true
  type    = bool
}

variable "cloud_init_storage_pool" {
  default = "local-lvm"
  type    = string
}

variable "boot_command" {
  default = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
}

variable "boot" {
  default = "c"
  type    = string
}

variable "boot_wait" {
  default = "5s"
  type    = string
}

variable "ssh_timeout" {
  default = "20m"
  type    = string
}




locals {
  user_data = {
    ssh_user = var.ssh_user
    ssh_pass = var.ssh_pass_hash
    # you can generate a password hash with mkpasswd -m sha-512
    # I had issues 
  }
}


############################################
#                                          #
#          source block                    #
#                                          #
############################################



source "proxmox-iso" "build" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = true

  node    = var.proxmox_node
  vm_name = var.vm_name

  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url

  iso_storage_pool = var.iso_storage_pool
  unmount_iso      = var.unmount_iso

  qemu_agent = var.qemu_agent

  scsi_controller = var.scsi_controller

  dynamic "disks" {
    for_each = var.disks
    content {
      disk_size    = disks.value["disk_size"]
      storage_pool = disks.value["storage_pool"]
      type         = disks.value["type"]
    }
  }

  memory = var.memory
  cores  = var.cores

  dynamic "network_adapters" {
    for_each = var.network_adapters
    content {
      model    = network_adapters.value["model"]
      bridge   = network_adapters.value["bridge"]
      firewall = network_adapters.value["firewall"]
    }
  }

  cloud_init              = var.cloud_init
  cloud_init_storage_pool = var.cloud_init_storage_pool

  boot_command = var.boot_command

  boot      = var.boot
  boot_wait = var.boot_wait

  http_content = {
    "/meta-data" = file("http/meta-data")
    "/user-data" = templatefile("http/user-data.tpl", local.user_data)
  }

  ssh_username = var.ssh_user
  ssh_password = var.ssh_pass
  ssh_timeout  = var.ssh_timeout
}


############################################
#                                          #
#          build block                     #
#                                          #
############################################

build {
  name    = var.vm_name
  sources = ["source.proxmox-iso.build"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }

  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl stop ufw",
      "sudo systemctl disable ufw",
      "sudo sed -i '/ swap /s/^/#/' /etc/fstab",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt install -y apt-transport-https ca-certificates curl gnupg containerd nfs-common",
      "sudo mkdir -p /etc/containerd",
      "sudo chmod 755 /etc/containerd",
      "sudo containerd config default | sudo tee /etc/containerd/config.toml",
      "sudo sed -i '/^.*SystemdCgroup.*$/c\\            SystemdCgroup = true' /etc/containerd/config.toml",
      "sudo systemctl restart containerd",
      "echo 'br_netfilter' | sudo tee -a /etc/modules-load.d/k8s.conf",
      "sudo modprobe br_netfilter",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | sudo tee -a /etc/sysctl.d/k8s.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | sudo tee -a /etc/sysctl.d/k8s.conf",
      "sudo sysctl --system"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL  https://pkgs.k8s.io/core:/stable:/v${var.kube_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${var.kube_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubeadm kubelet kubectl",
      "sudo systemctl enable --now kubelet",
      "sudo snap install helm --classic"
    ]
  }

}
