provider "postgresql" {
  host            = aws_db_instance.jumia_db.address
  port            = var.db_port
  database        = var.db_name
  username        = var.db_user
  password        = var.db_secure_pass
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
  
  expected_version = "13.7"
}


resource "aws_security_group" "postgres_sg" {
  name = "postgres_sg"
  vpc_id = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    description = "SSH connection to DB"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    description      = "Application connection to DB"
    cidr_blocks      = ["10.0.2.0/24", "10.0.3.0/24"]
  }
}

resource "aws_db_subnet_group" "db-subnet" {
  name       = "db_priv_subnet_group"
  subnet_ids = ["subnet-0ef47618d0d2761ed", "subnet-0bbd883f2d6b757a4" ]
}

resource "aws_db_instance" "jumia_db" {
  allocated_storage      = 400
  storage_type           = "gp3"
  engine                 = "postgres"
  engine_version         = "13.7"
  instance_class         = var.db_instance_class
  identifier             = var.db_identifier
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_secure_pass
  publicly_accessible    = false
  parameter_group_name   = "default.postgres13"
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  skip_final_snapshot    = true
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name

  tags = {
    "Name" = var.db_name
  }
}

# resource "postgresql_role" "user_name" {
#   name                = var.db_user
#   login               = true
#   password            = var.db_secure_pass
#   encrypted_password  = true
#   create_database     = true
#   create_role         = true
#   skip_reassign_owned = true
# }