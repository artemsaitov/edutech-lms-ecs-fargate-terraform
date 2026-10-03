terraform {
  backend "s3" {
    bucket       = "edutech-lms-terraform-state-927678863298"
    key          = "edutech-lms/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}