terraform {
  required_providers {
    pihole = {
      source  = "iolave/pihole"
      version = "0.2.2-beta.2"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc01"
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

