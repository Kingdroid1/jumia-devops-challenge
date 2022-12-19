terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.18.0"
    }
  }

}

provider "aws" {
  region  = var.aws_region
}