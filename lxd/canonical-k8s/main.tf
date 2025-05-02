resource "lxd_project" "k8s_project" {
  name        = var.project_name
  description = "Create a project for Canonical K8s environment"
  config      = {
    "features.images"          = true
    "features.networks"        = true
    "features.networks.zones"  = true
    "features.profiles"        = true
    "features.storage.buckets" = true
    "features.storage.volumes" = true
  }
}

resource "lxd_profile" "project_profile" {
  depends_on = [lxd_project.k8s_project]
  name       = var.project_profile_name
  project    = lxd_project.k8s_project.name

  config = {}

  device {
    name       = "eth0"
    type       = "nic"
    properties = {
      name     = "eth0"
      nictype  = "bridged"
      parent   = var.provider_bridge
    }
  }

  device {
    type       = "disk"
    name       = "root"
    properties = {
      pool     = "remote"
      path     = "/"
      size     = "15GiB"
    }
  }
}

resource "lxd_cached_image" "noble" {
  depends_on = [lxd_project.k8s_project]
  source_remote = "ubuntu"
  source_image  = "noble/amd64"
  type          = "virtual-machine"
  project       = lxd_project.k8s_project.name
}

resource "lxd_instance" "k8s_vm1" { 
  depends_on = [
    lxd_cached_image.noble,
    lxd_profile.project_profile,
  ]
  name       = "k8s-vm1"
  image      = lxd_cached_image.noble.fingerprint
  #image      = "ubuntu:24.04"
  profiles   = [var.project_profile_name]
  project    = lxd_project.k8s_project.name
  type       = "virtual-machine"
  target     = var.vm1_target_node
  limits     = {
    cpu = 2
    memory = "4GiB"
  }
 
  config = {
    "cloud-init.network-config" = <<-EOF
    version: 2
    ethernets:
      enp5s0:
        dhcp4: false
        dhcp6: false
        addresses: [${var.vm1_address}/24]
        routes:
          - to: default
            via: ${var.ext_net_gw}
        nameservers:
          addresses: [${var.vm_dns_address}]
    EOF
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    users:
    - name: ubuntu
      shell: /bin/bash
      sudo: ["ALL=(ALL) NOPASSWD:ALL"]
      ssh-authorized-keys: [${var.ssh_pub_key}]
    EOF
  }
}

resource "null_resource" "bootstrap_k8s" {
  depends_on  = [lxd_instance.k8s_vm1]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.vm1_address
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo snap install k8s --channel 1.33-classic/stable --classic",
      "sudo k8s bootstrap",
      "sudo k8s status --wait-ready",
      "sudo k8s get-join-token k8s-vm2 > /home/ubuntu/vm2.token",
      "sudo k8s get-join-token k8s-vm3 > /home/ubuntu/vm3.token",
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
    scp -i ${var.ssh_private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${var.vm1_address}:/home/ubuntu/vm2.token ./vm2.token
    scp -i ${var.ssh_private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${var.vm1_address}:/home/ubuntu/vm3.token ./vm3.token
    EOT
  }
}

data "local_file" "vm2_token" {
  depends_on = [null_resource.bootstrap_k8s]
  filename   = "${path.module}/vm2.token"
}

data "local_file" "vm3_token" {
  depends_on = [null_resource.bootstrap_k8s]
  filename   = "${path.module}/vm3.token"
}

resource "lxd_instance" "k8s_vm2" { 
  depends_on = [
    null_resource.bootstrap_k8s,
  ]
  name       = "k8s-vm2"
  image      = lxd_cached_image.noble.fingerprint
  #image      = "ubuntu:24.04"
  profiles   = [var.project_profile_name]
  project    = lxd_project.k8s_project.name
  type       = "virtual-machine"
  target     = var.vm2_target_node
  limits     = {
    cpu = 2
    memory = "4GiB"
  }
 
  config = {
    "cloud-init.network-config" = <<-EOF
    version: 2
    ethernets:
      enp5s0:
        dhcp4: false
        dhcp6: false
        addresses: [${var.vm2_address}/24]
        routes:
          - to: default
            via: ${var.ext_net_gw}
        nameservers:
          addresses: [${var.vm_dns_address}]
    EOF
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    users:
    - name: ubuntu
      shell: /bin/bash
      sudo: ["ALL=(ALL) NOPASSWD:ALL"]
      ssh-authorized-keys: [${var.ssh_pub_key}]
    EOF
  }
}

resource "null_resource" "add_vm2" {
  depends_on = [
    lxd_instance.k8s_vm2
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.vm2_address
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo snap install k8s --channel 1.33-classic/stable --classic",
      "sudo k8s join-cluster $(echo '${data.local_file.vm2_token.content}')",
    ]
  }
}

resource "lxd_instance" "k8s_vm3" { 
  depends_on = [
    lxd_instance.k8s_vm2
  ]
  name       = "k8s-vm3"
  image      = lxd_cached_image.noble.fingerprint
  #image      = "ubuntu:24.04"
  profiles   = [var.project_profile_name]
  project    = lxd_project.k8s_project.name
  type       = "virtual-machine"
  target     = var.vm3_target_node
  limits     = {
    cpu = 2
    memory = "4GiB"
  }
 
  config = {
    "cloud-init.network-config" = <<-EOF
    version: 2
    ethernets:
      enp5s0:
        dhcp4: false
        dhcp6: false
        addresses: [${var.vm3_address}/24]
        routes:
          - to: default
            via: ${var.ext_net_gw}
        nameservers:
          addresses: [${var.vm_dns_address}]
    EOF
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    users:
    - name: ubuntu
      shell: /bin/bash
      sudo: ["ALL=(ALL) NOPASSWD:ALL"]
      ssh-authorized-keys: [${var.ssh_pub_key}]
    EOF
  }
}

resource "null_resource" "add_vm3" {
  depends_on = [
    lxd_instance.k8s_vm3,
    null_resource.add_vm2
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.vm3_address
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo snap install k8s --channel 1.33-classic/stable --classic",
      "sudo k8s join-cluster $(echo '${data.local_file.vm3_token.content}')",
    ]
  }
}

resource "null_resource" "enable_lb" {
  depends_on  = [null_resource.add_vm3]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.vm1_address
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo k8s enable load-balancer",
      "sudo k8s set load-balancer.cidrs='192.168.150.250-192.168.150.254'",
      "sleep 30",
      "sudo k8s kubectl wait --for=condition=Ready pods --all -A --timeout=180s"
    ]
  }
}
