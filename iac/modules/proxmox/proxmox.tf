provider "proxmox" {
  pm_api_url = "https://proxmox.lotds.duckdns.org/api2/json"
  pm_debug   = true
}

data "external" "password_hash" {
  program = ["python3", "${path.module}/generate_hash.py"]

  query = {
    password = var.pve_password
  }
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "vm_memory_mb" {
  description = "The amount of memory of a given machine in megabytes"
  type        = number
  default     = 2048
}

resource "null_resource" "cloud_init_user_config_files" {
  count = var.vm_count
  connection {
    type     = "ssh"
    host     = var.pve_host
    user     = var.pve_user
    password = var.pve_password
  }

  provisioner "file" {
    content = templatefile("${path.module}/cloud-init/user.yaml",
      {
        hostname                  = "ubuntu-${count.index + 1}",
        mkpasswd_sha_512_password = data.external.password_hash.result["hash"]
        ssh_pub_key               = file(var.ssh_pub_key_path),
      }
    )
    destination = "/var/lib/vz/snippets/user_data_vm-${count.index + 1}.yml"
  }
  triggers = {
    content = file("${path.module}/cloud-init/user.yaml")
  }
}

resource "null_resource" "cloud_init_network_config_files" {
  count = var.vm_count
  connection {
    type     = "ssh"
    host     = var.pve_host
    user     = var.pve_user
    password = var.pve_password
  }

  provisioner "file" {
    content = templatefile("${path.module}/cloud-init/network.yaml",
      {
        machine_ip = "192.168.100.${204 + count.index}",
      }
    )
    destination = "/var/lib/vz/snippets/network_data_vm-${count.index + 1}.yaml"
  }
  triggers = {
    content = file("${path.module}/cloud-init/network.yaml")
  }
}

resource "proxmox_vm_qemu" "cloudinit-test" {
  count = var.vm_count
  depends_on = [
    null_resource.cloud_init_user_config_files,
    null_resource.cloud_init_network_config_files,
  ]

  name        = "ubuntu4"
  vmid        = 404 + count.index
  desc        = "tofu test"
  target_node = "napoleao"

  clone     = "Ubuntu-Noble-Template"
  cicustom  = "user=local:snippets/user_data_vm-${count.index + 1}.yml,network=local:snippets/network_data_vm-${count.index + 1}.yaml"
  ciupgrade = true
  os_type   = "cloud-init"

  memory  = var.vm_memory_mb
  balloon = var.vm_memory_mb / 2

  scsihw = "virtio-scsi-pci"
  agent  = 1

  skip_ipv6     = true
  agent_timeout = 20

  cpu {
    cores = 2
    type  = "kvm64"
  }

  network {
    id        = 0
    bridge    = "vmbr0"
    firewall  = false
    link_down = false
    model     = "virtio"
  }

  vga {
    type = "serial0"
  }

  # disk {
  #   type    = "cloudinit"
  #   slot    = "ide2"
  #   storage = "local-lvm"
  # }

  # disk {
  #   type        = "disk"
  #   disk_file   = "local-lvm:vm-${404 + count.index}-disk-0"
  #   passthrough = true
  #   replicate   = true
  #   slot        = "scsi0"
  # }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }

    scsi {
      scsi0 {
        passthrough {
          replicate = true
          file      = "local-lvm:vm-${404 + count.index}-disk-0"
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

}

