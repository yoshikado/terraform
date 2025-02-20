variable "network_name" {
  description = "Name of the network."
  type        = string
}

variable "project_name" {
  description = "Name of the project where the network will be created"
  type        = string
}

variable "lxd_cluster_node1" {
  description = "LXD cluster node1 hostname"
  type        = string
}

variable "lxd_cluster_node2" {
  description = "LXD cluster node2 hostname"
  type        = string
}

variable "lxd_cluster_node3" {
  description = "LXD cluster node3 hostname"
  type        = string
}
