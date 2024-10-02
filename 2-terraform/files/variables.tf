variable "proxmox_username" {
  type        = string
  description = "Your linux session username"
}

variable "proxmox_password" {
  type        = string
  description = "Your linux session password"
}

variable "vm_username" {
  type        = string
  description = "Your linux session username"
}

variable "vm_password" {
  type        = string
  description = "Your linux session password"
}

variable "proxmox_host_ip" {
  type        = string
  description = "IP address of your Proxmox host (ex: 192.168.0.10)"
}

variable "k8s_master_ip" {
  type        = string
  description = "IP address you want for your kubernetes master (ex: 192.168.0.60)"
}

variable "k8s_worker_ips" {
  type        = list(string)
  description = "List of IP addresses you want for your kubernetes workers"
  default     = []
}

variable "storage_pool_name" {
  type        = string
  description = "Name of the storage pool you want to use to store the VM disk"
}

variable "subnet_gw" {
  type        = string
  description = "IP address of your subnet gateway (ex: 192.168.0.1)"
}

variable "subnet_mask" {
  type        = string
  description = "Subnet mask you want to use in CIDR format (ex: /24)"
}

variable "pve_node_name" {
  type        = string
  description = "Name of your PVE node name (ex: proxmox)"
}

variable "template_name" {
  type        = string
  description = "Name of the template you want to clone"
}