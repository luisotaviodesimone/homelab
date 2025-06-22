variable "pihole_password" {
  description = "Pi-hole admin password"
  type        = string
  sensitive   = true
}

variable "ssh_pub_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "pve_host" {
  description = "Proxmox VE host"
  type        = string
  default    = "napoleao.lotds.duckdns.org"
}

variable "pve_user" {
  description = "Proxmox VE user"
  type        = string
  default     = "root"
}

variable "pve_password" {
  description = "Proxmox VE password"
  type        = string
  sensitive   = true
}
