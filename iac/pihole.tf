provider "pihole" {
  url      = "https://pihole.lotds.duckdns.org" # PIHOLE_URL
  password = var.pihole_password                # PIHOLE_PASSWORD
}

resource "pihole_dns_record" "ubuntu1" {
  domain = "ubuntu1.lotds.duckdns.org"
  ip     = "192.168.100.201"
}

resource "pihole_dns_record" "ubuntu2" {
  domain = "ubuntu2.lotds.duckdns.org"
  ip     = "192.168.100.202"
}

resource "pihole_dns_record" "ubuntu3" {
  domain = "ubuntu3.lotds.duckdns.org"
  ip     = "192.168.100.203"
}

resource "pihole_dns_record" "napoleao" {
  domain = "napoleao.lotds.duckdns.org"
  ip     = "192.168.100.111"
}

