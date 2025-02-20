resource "terraform_data" "lxd_add_user_project" {
  input = {
    ssh_user         = var.ssh_user
    ssh_host         = var.ssh_host
    ssh_private_key  = var.ssh_private_key
    user_name        = var.user_name
    group_name       = var.group_name
    project_name     = var.project_name
    entitlement      = var.entitlement
    client_cert_path = var.client_cert_path
  }

  connection {
    type        = "ssh"
    user        = self.input.ssh_user
    host        = self.input.ssh_host
    private_key = file(self.input.ssh_private_key)
  }

  provisioner "file" {
    source      = self.input.client_cert_path
    destination = basename(self.input.client_cert_path)
  }

  provisioner "remote-exec" {
    inline = [
      "lxc auth group create ${self.input.group_name}",
      "lxc auth group permission add ${self.input.group_name} project ${self.input.project_name} ${self.input.entitlement}",
      "lxc auth identity create tls/${self.input.user_name} ${basename(self.input.client_cert_path)} -g ${self.input.group_name}",
    ]
    when = create
  }

  provisioner "remote-exec" {
    inline = [
      "lxc auth identity delete tls/${self.input.user_name}",
      "lxc auth group delete ${self.input.group_name}",
    ]
    when = destroy
  }

}
