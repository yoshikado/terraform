terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
      version = "2.4.0"
    }
  }
}

resource "lxd_network" "network_node1" {
  name    = var.network_name
  project = var.project_name
  target  = var.lxd_cluster_node1
}

resource "lxd_network" "network_node2" {
  name    = var.network_name
  project = var.project_name
  target  = var.lxd_cluster_node2
}

resource "lxd_network" "network_node3" {
  name    = var.network_name
  project = var.project_name
  target  = var.lxd_cluster_node3
}

resource "lxd_network" "network" {
  depends_on = [
    lxd_network.network_node1,
    lxd_network.network_node2,
    lxd_network.network_node3,
  ]
  name    = var.network_name
  project = var.project_name
}