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

# SSH
variable "ssh_user" {
  description = "Username to SSH into the infra node"
  type        = string
  default     = "ubuntu"
}
variable "ssh_host" {
  description = "IP address/Host of the machine to remote into"
  type        = string
}
variable "ssh_private_key" {
  description = "SSH private key name of the remote machine"
  type        = string
}

# add_user
variable "project1_client_cert_path" {
  description = "X.509 certificate to be trusted by the LXD server"
  type        = string
}
variable "project2_client_cert_path" {
  description = "X.509 certificate to be trusted by the LXD server"
  type        = string
}
variable "project1_name" {
  description = "LXD project name for the first project"
  type        = string
  default     = "project1"
}
variable "project2_name" {
  description = "LXD project name for the second project"
  type        = string
  default     = "project2"
}
variable "project1_group_name" {
  description = "LXD group name for the first project"
  type        = string
  default     = "project1_group"
}
variable "project2_group_name" {
  description = "LXD group name for the second project"
  type        = string
  default     = "project2_group"
}
variable "project1_user_name" {
  description = "LXD user name for the first project"
  type        = string
  default     = "project1_user"
}
variable "project2_user_name" {
  description = "LXD user name for the second project"
  type        = string
  default     = "project2_user"
}
variable "project1_entitlement" {
  description = "Permission entitlement for the group in the first project"
  type        = string
  default     = "operator"
}
variable "project2_entitlement" {
  description = "Permission entitlement for the group in the second project"
  type        = string
  default     = "viewer"
}

# create network
variable "project1_network_name" {
  description = "Name of the network for project1."
  type        = string
  default     = "project1_network"
}
variable "project2_network_name" {
  description = "Name of the network for project2."
  type        = string
  default     = "project2_network"
}

# create profile
variable "project1_profile_name" {
  description = "Name of the profile for project1."
  type        = string
  default     = "project1_profile"
}
variable "project2_profile_name" {
  description = "Name of the profile for project2."
  type        = string
  default     = "project2_profile"
}
variable "ssh_pub_key" {
  description = "SSH public key to send to containers/VMs via cloud-init"
  type        = string
}
variable "vm_dns_address" {
  description = "DNS address for VMs"
  type        = string
}

# Forward IP addresses for containers 
# Select from subnet configured for UPLINK 
variable "container1_address" {
  description = "Floating IP address for container1"
  type        = string
}
variable "container2_address" {
  description = "Floating IP address for container2"
  type        = string
}

# IP addresses for VMs
variable "provider_bridge" {
  description = "The bridge name that connects to the external network"
  type        = string
}
variable "ext_net_gw" {
  description = "Gateway address for the external network"
  type        = string
}
variable "vm1_cidr_address" {
  description = "External IP address for vm1"
  type        = string
}
variable "vm2_cidr_address" {
  description = "External IP address for vm2"
  type        = string
}

