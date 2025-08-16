resource "vault_policy" "admin" {
  name   = "admin"
  policy = <<EOT
  # Manage namespaces
  path "sys/namespaces/*" {
     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  # Manage policies
  path "sys/policies/acl/*" {
     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  # List policies
  path "sys/policies/acl" {
     capabilities = ["list"]
  }

  # Enable and manage secrets engines
  path "sys/mounts/*" {
     capabilities = ["create", "read", "update", "delete", "list"]
  }

  # List available secrets engines
  path "sys/mounts" {
    capabilities = [ "read" ]
  }

  # Create and manage entities and groups
  path "identity/*" {
     capabilities = ["create", "read", "update", "delete", "list"]
  }

  # Manage auth
  path "auth/*" {
     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
EOT
}
