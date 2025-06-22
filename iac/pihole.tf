provider "pihole" {
  url      = "https://pihole.lotds.duckdns.org" # PIHOLE_URL
  password = var.pihole_password                # PIHOLE_PASSWORD
}

variable "dns_records" {
  type = map(string)
  default = {
    "gatekeeper.lotds.duckdns.org" = "192.168.100.200"
    "napoleao.lotds.duckdns.org"   = "192.168.100.111"
    "samba.lotds.duckdns.org"      = "192.168.100.200"
    "ubuntu1.lotds.duckdns.org"    = "192.168.100.201"
    "ubuntu2.lotds.duckdns.org"    = "192.168.100.202"
    "ubuntu3.lotds.duckdns.org"    = "192.168.100.203"
  }
}

resource "pihole_dns_record" "records" {
  for_each = var.dns_records

  domain = each.key
  ip     = each.value
}

