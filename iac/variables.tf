variable "pihole_password" {
  description = "Pi-hole admin password"
  type        = string
  sensitive   = true
}

variable "pve_password" {
  description = "Proxmox VE password"
  type        = string
  sensitive   = true
}

