terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "matthew.schroeder@gdit.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = "${acme_registration.reg.account_key_pem}"
  common_name               = "*.gditsolutiondemo.com"

  dns_challenge {
    provider = "route53"
  }
}

output "private_key_pem" {
  value = nonsensitive(lookup(acme_certificate.certificate, "private_key_pem"))
}

output "certificate_pem" {
  value = lookup(acme_certificate.certificate, "certificate_pem")
}

output "issuer_pem" {
  value = lookup(acme_certificate.certificate, "issuer_pem")
}
