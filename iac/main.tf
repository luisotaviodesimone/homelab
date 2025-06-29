terraform {
  required_providers {
    pihole = {
      source  = "iolave/pihole"
      version = "0.2.2-beta.2"
    }
    nginxproxymanager = {
      source  = "home-devops/nginxproxymanager"
      version = "1.1.3"
    }
  }
  backend "s3" {
    bucket = "opentofu"
    key    = "terraform.tfstate"

    endpoints = {
      s3 = "https://minioapi.lotds.duckdns.org"
    }

    region                      = "main"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

locals {
  vms = yamldecode(file("${path.module}/vms.yaml"))
}

module "proxmox" {
  source           = "./modules/proxmox"

  vms              = local.vms
  ssh_pub_key_path = "~/.ssh/id_rsa.pub"
  pve_host         = "proxmox.lotds.duckdns.org"
  pve_password     = var.pve_password
}
