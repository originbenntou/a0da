output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

output "route_table_id" {
  value = aws_route_table.main.id
}
