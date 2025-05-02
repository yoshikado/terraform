terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
      version = "2.4.0"
    }
  }
}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate = true

  remote {
    name    = var.lxd_remote_name
    address = var.lxd_remote_addr
    default = true
  }
}