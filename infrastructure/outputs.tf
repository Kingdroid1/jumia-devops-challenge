output "loadbalancer_IP" {
    value = aws_lb.prod-lb.dns_name
}

output "security_group_id" {
    value = aws_security_group.allow_web.id
}
output "postgres_db_name" {
    value = aws_db_instance.jumia_db.db_name
}

output "postgres_db_url" {
    value = aws_db_instance.jumia_db.endpoint
}

output "db_security_group_id" {
    value = aws_security_group.postgres_sg.id
}

output "vpc_id" {
    value = aws_vpc.prod_vpc.id
}

output "private_subnet_id-1" {
    value = aws_subnet.private_subnet1.id
}

output "private_subnet_id-2" {
    value = aws_subnet.private_subnet2.id
}