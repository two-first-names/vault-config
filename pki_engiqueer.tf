resource "vault_mount" "pki_engiqueer" {
  path        = "pki_engiqueer"
  type        = "pki"
  description = "This is an example intermediate PKI mount"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 157680000

  allowed_response_headers = [
    "Last-Modified",
    "Location",
    "Replay-Nonce",
    "Link"
  ]

  passthrough_request_headers = [
    "If-Modified-Since"
  ]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_engiqueer" {
  backend     = vault_mount.pki_engiqueer.path
  type        = "internal"
  common_name = "engiqueer.net Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_engiqueer" {
  backend     = vault_mount.pki_root.path
  common_name = "engiqueer.net Intermediate CA"
  csr         = vault_pki_secret_backend_intermediate_cert_request.pki_engiqueer.csr
  format      = "pem_bundle"
  ttl         = 15480000
  issuer_ref  = vault_pki_secret_backend_root_cert.root_2025.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_engiqueer.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_engiqueer.certificate
}

resource "vault_pki_secret_backend_role" "pki_engiqueer" {
  backend          = vault_mount.pki_engiqueer.path
  name             = "engiqueer-net"
  ttl              = 86400
  max_ttl          = 2592000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["engiqueer.net"]
  allow_subdomains = true
  server_flag      = true
  client_flag      = true
}

resource "vault_pki_secret_backend_config_cluster" "pki_engiqueer" {
  backend  = vault_mount.pki_engiqueer.path
  path     = "https://vault.engiqueer.net:8200/v1/${vault_mount.pki_engiqueer.path}"
  aia_path = "https://vault.engiqueer.net:8200/v1/${vault_mount.pki_engiqueer.path}"
}

resource "vault_pki_secret_backend_config_acme" "pki_engiqueer" {
  backend                  = vault_mount.pki_engiqueer.path
  enabled                  = true
  allowed_issuers          = ["*"]
  allowed_roles            = [vault_pki_secret_backend_role.pki_engiqueer_acme.name]
  allow_role_ext_key_usage = true
  default_directory_policy = "role:${vault_pki_secret_backend_role.pki_engiqueer_acme.name}"
  dns_resolver             = ""
  eab_policy               = "not-required"
}

resource "vault_pki_secret_backend_role" "pki_engiqueer_acme" {
  backend          = vault_mount.pki_engiqueer.path
  name             = "acme"
  ttl              = 86400
  max_ttl          = 2592000
  allow_ip_sans    = true
  key_type         = "any"
  key_bits         = 4096
  allowed_domains  = ["engiqueer.net", "pcs-proud.org.uk", "agender.org.uk", "ukgovcamp.com"]
  ext_key_usage    = ["ServerAuth", "ClientAuth"]
  allow_subdomains = true
  server_flag      = true
  client_flag      = true
}


resource "vault_pki_secret_backend_role" "pki_engiqueer_host" {
  backend                  = vault_mount.pki_engiqueer.path
  name                     = "hosts"
  ttl                      = 86400
  max_ttl                  = 2592000
  allow_ip_sans            = true
  key_type                 = "rsa"
  key_bits                 = 4096
  allowed_domains          = ["{{ identity.entity.aliases.auth_cert_421f2f2d.name }}"]
  allowed_domains_template = true
  allow_bare_domains       = true
  allow_subdomains         = true
  server_flag              = true
  client_flag              = true
}

resource "vault_policy" "pki_hosts" {
  name = "pki-hosts"

  policy = <<EOT
    path "pki_engiqueer/issue/hosts" {
      capabilities = ["create", "update"]
    }
  EOT
}
