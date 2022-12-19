terraform {
  backend "s3" {
    bucket         = "prod-env-tfstate-1"
    key            = "workspaces/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
  }
}