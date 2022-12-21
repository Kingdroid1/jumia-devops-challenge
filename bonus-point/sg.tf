resource "aws_security_group" "node_group_sg" {
  name_prefix = "node_group_sg"
  vpc_id      = data.aws_vpc.prod_vpc.id

  ingress {
    from_port = 1337
    to_port   = 1337
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################
# create private and public subnets in AZs
################################################
data "aws_availability_zones" "available" {
    state = "available"
}
data "aws_vpc" "prod_vpc" {}

resource "aws_subnet" "private_subnets" {
    count = 3
    vpc_id = data.aws_vpc.prod_vpc.id
    cidr_block        = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    availability_zone = slice(data.aws_availability_zones.available.names,0,4)

    tags = {
      "kubernetes.io/cluster/${aws_eks_cluster.jumia}" = "shared"
      "kubernetes.io/role/internal-elb"                 = 1
    }
}

resource "aws_subnet" "public_subnets" {
    count = 3
    vpc_id = data.aws_vpc.prod_vpc.id
    cidr_block        = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
    availability_zone = slice(data.aws_availability_zones.available.names,0,4)

    tags = {
       "kubernetes.io/cluster/${aws_eks_cluster.jumia}" = "shared"
       "kubernetes.io/role/elb"                          = 1
    }
}
