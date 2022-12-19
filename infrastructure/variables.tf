variable "aws_region" {
    type = string
    description = "AWS region in which to deploy infrastructure"
    default = "eu-central-1"
}

variable "vpc_cidr" {
    type = string
    description = "VPC to deploy infra resources in"
    default = "10.0.0.0/16"
}

variable "subnet_prefix" {
    default = [{ cidr_block = "10.0.0.0/24", name = "public-1" }, { cidr_block = "10.0.1.0/24", name = "public-2" }, { cidr_block = "10.0.2.0/24", name = "private-1" }, { cidr_block = "10.0.3.0/24", name = "private-4" }]
}

variable "availability_zone1a" {
    type = string
    description = "first AZ"
    default = "eu-central-1a"
}

variable "availability_zone1b" {
    type = string
    description = "second AZ"
    default = "eu-central-1b"
}

variable "instance_type" {
    type = string
    description = "type of AMI instance to use"
    default = "c6g.large"
}

variable "ami" {
    type = string
    description = "AMI id"
    default = "ami-074bcbbba36789937"
}

#######################################################
# Variables for Postgres Database Setup
#######################################################
variable "db_identifier" {
    type = string
    default = "jumia-phone-validator"
}

variable "db_name" {
    type = string
    default = "jumia_phone_validator"
}

variable "db_user" {
    type = string
    default = "jumia"
}

variable "db_secure_pass" {
    type = string
    default = "jumiAjkhBhdsh"
}

variable "db_instance_name" {
    type = string
    default = "jumia_db"
}

variable "db_port" {
    type = number
    default = 5432
}

variable "db_instance_class" {
    type = string
    default = "db.m6i.large"
}