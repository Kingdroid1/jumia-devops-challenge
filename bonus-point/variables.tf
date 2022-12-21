variable "aws_region" {
    type = string
    description = "AWS region in which to deploy infrastructure"
    default = "eu-central-1"
}

variable "vpc_id" {
    type = string
    default = "vpc-066a0ca5f533422b1"
}