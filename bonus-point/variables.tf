variable "aws_region" {
    type = string
    description = "AWS region in which to deploy infrastructure"
    default = "eu-central-1"
}

variable "vpc_id" {
    type = string
    default = "vpc-066a0ca5f533422b1"
}

variable "pub_cidr_block" {
    type = string
    default = "10.0.7.0/24"
}

variable "priv_cidr_block" {
    type = string
    default = "10.0.10.0/24"
}

variable "cidrs" {
    type = list(string)
    default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}