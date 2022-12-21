resource "aws_security_group" "node_group_sg" {
  name_prefix = "node_group_sg"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port = 1337
    to_port   = 1337
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}