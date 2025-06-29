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

resource "null_resource" "cloud_init_user_config_files" {
  for_each = { for vm in var.vms : vm.name => vm }

  connection {
    type     = "ssh"
    host     = var.pve_host
    user     = var.pve_user
    password = var.pve_password
  }

  provisioner "file" {
    content = templatefile("${path.module}/cloud-init/user.yaml",
      {
        hostname                  = "${each.key}",
        mkpasswd_sha_512_password = data.external.password_hash.result["hash"]
        ssh_pub_key               = file(var.ssh_pub_key_path),
      }
    )
    destination = "/var/lib/vz/snippets/user_data_vm-${each.key}.yaml"
  }
  triggers = {
    content = file("${path.module}/cloud-init/user.yaml")
  }
}

resource "null_resource" "cloud_init_network_config_files" {
  for_each = { for vm in var.vms : vm.name => vm }

  connection {
    type     = "ssh"
    host     = var.pve_host
    user     = var.pve_user
    password = var.pve_password
  }

  provisioner "file" {
    content = templatefile("${path.module}/cloud-init/network.yaml",
      {
        machine_ip = each.value.networks[0].ip_address,
      }
    )
    destination = "/var/lib/vz/snippets/network_data_vm-${each.key}.yaml"
  }
  triggers = {
    content = file("${path.module}/cloud-init/network.yaml")
  }
}

resource "proxmox_vm_qemu" "cloudinit-test" {
  for_each = { for vm in var.vms : vm.name => vm }

  depends_on = [
    null_resource.cloud_init_user_config_files,
    null_resource.cloud_init_network_config_files,
  ]

  name        = each.value.name
  vmid        = each.value.vmid
  desc        = "tofu test"
  target_node = "napoleao"

  clone     = each.value.template
  cicustom  = "user=local:snippets/user_data_vm-${each.key}.yaml,network=local:snippets/network_data_vm-${each.key}.yaml"
  ciupgrade = true
  os_type   = "cloud-init"

  memory  = each.value.memory_mb
  balloon = each.value.memory_mb / 2

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
          file      = "local-lvm:vm-${each.value.vmid}-disk-0"
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

}
