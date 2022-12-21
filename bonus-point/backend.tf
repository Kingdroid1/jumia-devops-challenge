terraform {
  backend "s3" {
    bucket         = "bonus-eks-tfstate"
    key            = "workspaces/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "bonus-tfstate-lock"
    encrypt        = true
  }
}