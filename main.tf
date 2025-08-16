provider "vault" {}

locals {
  default_3y_in_sec  = 94608000
  default_1y_in_sec  = 31536000
  default_1hr_in_sec = 3600
}

terraform {
  backend "s3" {
    bucket                      = "engiqueer-tfstate"
    key                         = "vault.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints                   = { s3 = "https://5d41e2c30ffed40a965d347978df47a3.r2.cloudflarestorage.com" }
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.1.0"
    }
  }
}
