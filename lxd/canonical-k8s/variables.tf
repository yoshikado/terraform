# provider
variable "lxd_remote_name" {
  type        = string
  description = "Name of the LXD remote"
  default     = "lxd-remote"
}
variable "lxd_remote_addr" {
  type        = string
  description = "Remote address of the LXD cluster"
  default     = "https://127.0.0.1:8443"
}

variable "ssh_private_key" {
  description = "SSH private key name of the remote machine"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "project_name" {
  description = "LXD project name for the k8s project"
  type        = string
  default     = "k8s-project"
}

# create profile
variable "project_profile_name" {
  description = "Name of the profile for k8s project."
  type        = string
  default     = "k8s-profile"
}
variable "provider_bridge" {
  description = "Name of the bridge."
  type        = string
  default     = "br0"
}
variable "ssh_pub_key" {
  description = "SSH public key to send to containers/VMs via cloud-init"
  type        = string
}

# Target node for each VM
variable "vm1_target_node" {
  description = "Specify which node to provision the VM"
  type        = string
  default     = "node1"
}
variable "vm2_target_node" {
  description = "Specify which node to provision the VM"
  type        = string
  default     = "node2"
}
variable "vm3_target_node" {
  description = "Specify which node to provision the VM"
  type        = string
  default     = "node3"
}

# IP addresses for VMs
variable "ext_net_gw" {
  description = "Gateway address for the external network"
  type        = string
}
variable "vm1_address" {
  description = "External IP address for vm1"
  type        = string
}
variable "vm2_address" {
  description = "External IP address for vm1"
  type        = string
}
variable "vm3_address" {
  description = "External IP address for vm1"
  type        = string
}
variable "vm_dns_address" {
  description = "DNS address for VMs"
  type        = string
}

