module "add_client" {
  source          = "../modules/add_client"
  ssh_user        = var.ssh_user
  ssh_host        = var.ssh_host
  ssh_private_key = var.ssh_private_key
}

resource "lxd_project" "project1" {
  depends_on  = [module.add_client]
  name        = var.project1_name
  description = "Terraform provider example project1"
  config      = {
    "features.images"          = true
    "features.networks"        = true
    "features.networks.zones"  = true
    "features.profiles"        = true
    "features.storage.buckets" = true
    "features.storage.volumes" = true
  }
}

resource "lxd_project" "project2" {
  depends_on  = [module.add_client]
  name        = var.project2_name
  description = "Terraform provider example project2"
  config      = {
    "features.images"          = true
    "features.networks"        = true
    "features.networks.zones"  = true
    "features.profiles"        = true
    "features.storage.buckets" = true
    "features.storage.volumes" = true
  }
}

module "add_user_project1" {
  depends_on       = [lxd_project.project1]
  source           = "../modules/add_user"
  ssh_user         = var.ssh_user
  ssh_host         = var.ssh_host
  ssh_private_key  = var.ssh_private_key
  client_cert_path = var.project1_client_cert_path
  group_name       = var.project1_group_name
  user_name        = var.project1_user_name
  project_name     = lxd_project.project1.name
  entitlement      = var.project1_entitlement
}

module "add_user_project2" {
  depends_on       = [lxd_project.project2]
  source           = "../modules/add_user"
  ssh_user         = var.ssh_user
  ssh_host         = var.ssh_host
  ssh_private_key  = var.ssh_private_key
  client_cert_path = var.project2_client_cert_path
  group_name       = var.project2_group_name
  user_name        = var.project2_user_name
  project_name     = lxd_project.project2.name
  entitlement      = var.project2_entitlement
}

resource "lxd_network" "network_project1" {
  depends_on = [module.add_user_project1]
  name       = var.project1_network_name
  project    = lxd_project.project1.name
  type       = "ovn"
}

resource "lxd_network" "network_project2" {
  depends_on = [module.add_user_project2]
  name       = var.project2_network_name
  project    = lxd_project.project2.name
  type       = "ovn"
}

resource "lxd_profile" "project1_profile" {
  depends_on = [lxd_network.network_project1]
  name       = var.project1_profile_name
  project    = lxd_project.project1.name

  device {
    name       = "eth0"
    type       = "nic"
    properties = {
      name     = "eth0"
      network  = var.project1_network_name
    }
  }

  device {
    type       = "disk"
    name       = "root"
    properties = {
      pool     = "remote"
      path     = "/"
    }
  }
}

resource "lxd_profile" "project2_profile" {
  depends_on = [lxd_network.network_project2]
  name       = var.project2_profile_name
  project    = lxd_project.project2.name

  device {
    name       = "enp5s0"
    type       = "nic"
    properties = {
      name     = "enp5s0"
      nictype  = "bridged"
      parent   = "brexternal"
    }
  }

  device {
    type       = "disk"
    name       = "root"
    properties = {
      pool = "remote"
      path = "/"
      size = "15GiB"
    }
  }
}

resource "lxd_cached_image" "project1_noble" {
  depends_on = [module.add_user_project1]
  source_remote = "ubuntu"
  source_image  = "noble/amd64"
  type          = "container"
  project       = lxd_project.project1.name
}

resource "lxd_cached_image" "project2_noble" {
  depends_on = [module.add_user_project2]
  source_remote = "ubuntu"
  source_image  = "noble/amd64"
  type          = "virtual-machine"
  project       = lxd_project.project2.name
}

resource "lxd_instance" "container1" { 
  depends_on = [
    lxd_cached_image.project1_noble,
    lxd_profile.project1_profile,
  ]
  name       = "terraform-container1"
  image      = lxd_cached_image.project1_noble.fingerprint
  profiles   = [var.project1_profile_name]
  project    = lxd_project.project1.name
  type       = "container"

  config = {
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    ssh_import_id: lp:yoshikadokawa
    EOF
  }
}

resource "lxd_instance" "container2" { 
  depends_on = [
    lxd_cached_image.project1_noble,
    lxd_profile.project1_profile,
    lxd_instance.container1,
  ]
  name       = "terraform-container2"
  image      = lxd_cached_image.project1_noble.fingerprint
  profiles   = [var.project1_profile_name]
  project    = lxd_project.project1.name
  type       = "container"

  config = {
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    ssh_import_id: lp:yoshikadokawa
    EOF
  }
}

resource "lxd_instance" "vm1" { 
  depends_on = [
    lxd_cached_image.project2_noble,
    lxd_profile.project2_profile,
  ]
  name       = "terraform-vm1"
  image      = lxd_cached_image.project2_noble.fingerprint
  profiles   = [var.project2_profile_name]
  project    = lxd_project.project2.name
  type       = "virtual-machine"
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
        addresses: [${var.vm1_cidr_address}]
        routes:
          - to: default
            via: ${var.ext_net_gw}
        nameservers:
          addresses: [172.16.21.254]
    EOF
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    ssh_import_id: lp:yoshikadokawa
    EOF
  }
}

resource "lxd_instance" "vm2" { 
  depends_on = [
    lxd_cached_image.project2_noble,
    lxd_profile.project2_profile,
    lxd_instance.vm1,
  ]
  name       = "terraform-vm2"
  image      = lxd_cached_image.project2_noble.fingerprint
  profiles   = [var.project2_profile_name]
  project    = lxd_project.project2.name
  type       = "virtual-machine"
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
        addresses: [${var.vm2_cidr_address}]
        routes:
          - to: default
            via: ${var.ext_net_gw}
        nameservers:
          addresses: [172.16.21.254]
    EOF
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    ssh_import_id: lp:yoshikadokawa
    EOF
  }
}

resource "lxd_network_forward" "forward_container1" {
  network        = lxd_network.network_project1.name
  project        = lxd_project.project1.name
  listen_address = var.container1_address

  config = {
    target_address = lxd_instance.container1.ipv4_address
  }
}

resource "lxd_network_forward" "forward_container2" {
  network        = lxd_network.network_project1.name
  project        = lxd_project.project1.name
  listen_address = var.container2_address

  config = {
    target_address = lxd_instance.container2.ipv4_address
  }
}
