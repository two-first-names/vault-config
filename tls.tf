resource "vault_auth_backend" "cert" {
  path = "cert"
  type = "cert"
}

resource "vault_cert_auth_backend_role" "cert" {
  name           = "cert"
  certificate    = vault_pki_secret_backend_root_cert.root_2025.certificate
  backend        = vault_auth_backend.cert.path
  token_ttl      = 300
  token_max_ttl  = 600
  token_policies = [vault_policy.ssh_hosts.name, vault_policy.pki_hosts.name]
}
