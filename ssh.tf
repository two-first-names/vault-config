resource "vault_mount" "ssh_client" {
  path = "ssh_client"
  type = "ssh"
}

resource "vault_ssh_secret_backend_ca" "ssh_client" {
  backend              = vault_mount.ssh_client.path
  key_type             = "ed25519"
  generate_signing_key = true
}

resource "vault_mount" "ssh_host" {
  path = "ssh_host"
  type = "ssh"
}

resource "vault_ssh_secret_backend_ca" "ssh_host" {
  backend              = vault_mount.ssh_host.path
  key_type             = "ed25519"
  generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "hosts" {
  name                     = "hosts"
  backend                  = vault_mount.ssh_host.path
  key_type                 = "ca"
  allow_host_certificates  = true
  allowed_domains_template = true
  allowed_domains          = "{{ identity.entity.aliases.auth_cert_421f2f2d.name }}"
  allow_bare_domains       = true
}

resource "vault_policy" "ssh_hosts" {
  name = "ssh-hosts"

  policy = <<EOT
    path "ssh_host/sign/hosts" {
      capabilities = ["create", "update"]
    }
  EOT
}

resource "vault_ssh_secret_backend_role" "clients_admin" {
  name                    = "admin"
  backend                 = vault_mount.ssh_client.path
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = "admin@engiqueer.net"
  default_user            = "admin@engiqueer.net"
}
