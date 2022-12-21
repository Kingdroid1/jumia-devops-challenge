variable "aws_region" {
    type = string
    description = "AWS region in which to deploy infrastructure"
    default = "eu-central-1"
}

variable "vpc_id" {
    type = string
    default = "vpc-066a0ca5f533422b1"
}

variable "priv-subnet-1" {
    type = string
    default = "subnet-02d95f90ac08de832" 
}

variable "priv-subnet-2" {
    type = string
    default = "subnet-047af3185e0e62d4b" 
}
variable "pub_cidr_block" {
    type = string
    default = "10.0.9.0/24"
}

variable "priv_cidr_block" {
    type = string
    default = "10.0.8.0/24"
}

variable "cidrs" {
    type = list(string)
    default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}