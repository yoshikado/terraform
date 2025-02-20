terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}

provider "tls" {}

resource "tls_private_key" "client_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "client_cert" {
  private_key_pem = "${tls_private_key.client_key.private_key_pem}"

  subject {
    common_name  = "client"
  }

  validity_period_hours = 87600 # 10 years

  allowed_uses = [
   "digital_signature",
   "crl_signing",
   "cert_signing",
  ]
}

resource "local_file" "client_key_file" {
  filename = "client.key"
  content  = "${tls_private_key.client_key.private_key_pem}"
}

resource "local_file" "client_cert_file" {
  filename = "client.crt"
  content  = "${tls_self_signed_cert.client_cert.cert_pem}"
}
