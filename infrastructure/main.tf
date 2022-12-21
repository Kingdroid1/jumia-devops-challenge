###############################################################
# create virtual private cloud - vpc and associated resources
###############################################################
resource "aws_vpc" "prod_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "Production"
  }
}

resource "aws_internet_gateway" "aigw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    "Name" = "Production"
  }
}

# resource "aws_internet_gateway_attachment" "igw-attachment" {
#   internet_gateway_id = aws_internet_gateway.aigw.id
#   vpc_id              = aws_vpc.prod_vpc.id
# }

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = var.subnet_prefix[0].cidr_block
  availability_zone       = var.availability_zone1a
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = var.subnet_prefix[1].cidr_block
  availability_zone       = var.availability_zone1b
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_prefix[1].name
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = var.subnet_prefix[2].cidr_block
  availability_zone = var.availability_zone1a

  tags = {
    Name = var.subnet_prefix[2].name
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = var.subnet_prefix[3].cidr_block
  availability_zone = var.availability_zone1b

  tags = {
    Name = var.subnet_prefix[3].name
  }
}

resource "aws_eip" "prod-eip1" {
  vpc = true
  # depends_on = [
  #   aws_internet_gateway_attachment.igw-attachment
  # ]
}

resource "aws_eip" "prod-eip2" {
  vpc = true

  # depends_on = [
  #   aws_internet_gateway_attachment.igw-attachment
  # ]
}

resource "aws_nat_gateway" "prod-nat-gw1" {
  allocation_id = aws_eip.prod-eip1.allocation_id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "vpc_natgw"
  }

  depends_on = [
    aws_internet_gateway.aigw
  ]
}

resource "aws_nat_gateway" "prod-nat-gw2" {
  allocation_id = aws_eip.prod-eip2.allocation_id
  subnet_id     = aws_subnet.public_subnet2.id

  tags = {
    Name = "vpc_natgw"
  }

  depends_on = [
    aws_internet_gateway.aigw
  ]
}
resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aigw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.aigw.id
  }

  tags = {
    Name = "Prod-RT"
  }
}

resource "aws_route_table_association" "prod-rt-assoc1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.prod-rt.id
}

resource "aws_route_table_association" "prod-rt-assoc2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.prod-rt.id
}

resource "aws_route_table" "private-rt1" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.prod-nat-gw1.id
  }

  tags = {
    Name = "Private-RT1"
  }
}

resource "aws_route_table_association" "private-rt-assoc1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private-rt1.id
}

resource "aws_route_table" "private-rt2" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.prod-nat-gw2.id
  }

  tags = {
    Name = "Private-RT2"
  }
}

resource "aws_route_table_association" "private-rt-assoc2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private-rt2.id
}

#########################################################
# set up security and firewall rules to control traffic
##########################################################
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic to specific ports via loadbalancer"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Postgres DB connection"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#########################################################
# set up application LB, autoscaling group et al
#########################################################
resource "aws_launch_template" "instance-template" {
  name_prefix            = "prod-template"
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.allow_web.id}"]
  key_name               = "jumia-prod-key"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = "20"
      volume_type = "gp3"
    }

  }
  tags = {
    Name = "Production"
  }
  user_data = "${base64encode(<<EOF
  ${file("launch_config/linux.sh")}

  EOF
  )}"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "iam_user_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_autoscaling_group" "prod-asg" {
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  target_group_arns         = ["${aws_lb_target_group.http-tg.arn}", "${aws_lb_target_group.https-tg.arn}", "${aws_lb_target_group.ssh-tg.arn}"]

  launch_template {
    id      = aws_launch_template.instance-template.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "http-tg" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod_vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group" "https-tg" {
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.prod_vpc.id

  health_check {
    port     = 443
    protocol = "HTTPS"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group" "ssh-tg" {
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod_vpc.id
}

resource "aws_lb" "prod-lb" {
  name               = "prod-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  ip_address_type    = "ipv4"

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }

}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.prod-lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-central-1:992122884453:certificate/ba30bbe5-8f3a-4974-8c85-73e2f1f687d2"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https-tg.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http-tg.arn
  }
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.prod-lb.arn
  port              = 1337
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssh-tg.arn
  }
}

resource "aws_lb_listener_rule" "http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http-tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  condition {
    host_header {
      values = ["tizok8s.com"]
    }
  }
}

resource "aws_lb_listener_rule" "https" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https-tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  condition {
    host_header {
      values = ["tizok8s.com"]
    }
  }
}
