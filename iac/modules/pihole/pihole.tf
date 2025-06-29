variable "dns_records" {
  type = map(string)
  default = {
    "gatekeeper.lotds.duckdns.org" = "192.168.100.200"
    "napoleao.lotds.duckdns.org"   = "192.168.100.111"
    "samba.lotds.duckdns.org"      = "192.168.100.200"
  }
}

resource "pihole_dns_record" "records" {
  for_each = var.dns_records

  domain = each.key
  ip     = each.value
}

resource "pihole_dns_record" "additional_records" {
  for_each = { for vm in var.vms : vm.name => {
    domain = "${vm.name}.lotds.duckdns.org"
    ip   = vm.networks[0].ip_address
  } if vm.networks[0].ip_address != "" }

  domain = each.value.domain
  ip     = each.value.ip
}

