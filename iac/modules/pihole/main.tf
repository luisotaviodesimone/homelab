terraform {
  required_providers {
    pihole = {
      source  = "iolave/pihole"
      version = "0.2.2-beta.2"
    }
  }
}

provider "pihole" {
  url      = "https://pihole.lotds.duckdns.org" # PIHOLE_URL
  password = var.pihole_password                # PIHOLE_PASSWORD
}

