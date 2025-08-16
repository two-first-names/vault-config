resource "vault_jwt_auth_backend" "github" {
  description        = "JWT Auth Backend for GitHub Actions"
  path               = "jwt-github"
  bound_issuer       = "https://token.actions.githubusercontent.com"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
}

resource "vault_jwt_auth_backend_role" "github_admin" {
  backend         = vault_jwt_auth_backend.github.path
  role_name       = "github_admin"
  bound_audiences = ["https://github.com/two-first-names"]
  user_claim      = "sub"
  role_type       = "jwt"
  token_ttl       = 300
  token_type      = "service"
  token_policies  = [vault_policy.admin.name]
}
