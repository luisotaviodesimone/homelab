variable "ssh_pub_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  nullable    = false
}

variable "pve_host" {
  description = "Proxmox VE host"
  type        = string
  default     = "napoleao.lotds.duckdns.org"
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

variable "vm_memory_mb" {
  description = "The amount of memory of a given machine in megabytes"
  type        = number
  default     = 2048
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
