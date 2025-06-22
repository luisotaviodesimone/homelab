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

resource "local_file" "cloud_init_user_data_file" {
  count = var.vm_count
  content = templatefile("${path.module}/cloud-init/user.yaml",
    {
      hostname                  = "ubuntu-${count.index + 1}",
      mkpasswd_sha_512_password = data.external.password_hash.result["hash"]
      ssh_pub_key               = file(var.ssh_pub_key_path),
    }
  )
  filename = "ubuntu-${count.index + 1}-user.yaml"

  depends_on = [data.external.password_hash]
  lifecycle {
    ignore_changes = [content]
  }
}

resource "null_resource" "cloud_init_config_files" {
  count = var.vm_count
  connection {
    type     = "ssh"
    host     = var.pve_host
    user     = var.pve_user
    password = var.pve_password
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file[count.index].filename
    destination = "/var/lib/vz/snippets/user_data_vm-${count.index + 1}.yml"
  }
}

# resource "proxmox_vm_qemu" "pve" {
#   name        = "ubuntu4"
#   target_node = "napoleao"
#   clone_id    = "ubuntu-template"
#   full_clone  = true
#   vmid        = 404
#   cicustom    = <<EOT
#     user=ubuntu:ubuntu
#     sshkeys=${file("~/.ssh/id_rsa.pub")}
# EOT
# }
