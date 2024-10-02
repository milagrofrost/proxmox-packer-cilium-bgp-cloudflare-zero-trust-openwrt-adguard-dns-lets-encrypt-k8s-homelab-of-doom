terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
