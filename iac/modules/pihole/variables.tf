variable "pihole_password" {
  description = "Pi-hole admin password"
  type        = string
  sensitive   = true
}

variable "vms" {
  description = "List of VMs to manage"
  type = list(object({
    name      = string
    vmid      = number
    cores     = number
    memory_mb = number
    disks = map(object({
      size_gb = string
    }))
    template = string
    networks = list(object({
      ip_address = string
      netmask    = string
      gateway    = string
    }))
  }))
  nullable = false
}
