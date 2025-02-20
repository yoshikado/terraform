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

variable "client_cert_path" {
  description = "X.509 certificate to be trusted by the LXD server"
  type        = string
}

variable "group_name" {
  description = "LXD group name"
  type        = string
}

variable "user_name" {
  description = "LXD user name"
  type        = string
}

variable "project_name" {
  description = "LXD project name"
  type        = string
}

variable "entitlement" {
  description = "Permission entitlement for entity-type: project"
  type        = string
}
