terraform {
  required_providers {
    proxmox = {
      source = "thegameprofi/proxmox"
      version = "2.9.15"	
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://${var.proxmox_host_ip}:8006/api2/json"
  pm_user = var.proxmox_username
  pm_password = var.proxmox_password
}
