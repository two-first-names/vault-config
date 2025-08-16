resource "vault_mount" "pki_root" {
  path = "pki_root"
  type = "pki"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_root_cert" "root_2025" {
  backend     = vault_mount.pki_root.path
  type        = "internal"
  common_name = "engiqueer.net Root CA"
  ttl         = 315360000
  issuer_name = "root-2025"
}

resource "vault_pki_secret_backend_issuer" "root_2025" {
  backend                        = vault_mount.pki_root.path
  issuer_ref                     = vault_pki_secret_backend_root_cert.root_2025.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.root_2025.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

resource "vault_pki_secret_backend_role" "pki_root_role" {
  backend          = vault_mount.pki_root.path
  name             = "2025-servers"
  ttl              = 86400
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["engiqueer.net"]
  allow_subdomains = true
  allow_any_name   = true
}

resource "vault_pki_secret_backend_config_urls" "config-urls" {
  backend                 = vault_mount.pki_root.path
  issuing_certificates    = ["https://vault.engiqueer.net:8200/v1/pki_root/ca"]
  crl_distribution_points = ["https://vault.engiqueer.net:8200/v1/pki_root/crl"]
}
