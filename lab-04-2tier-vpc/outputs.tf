output "web_public_ip" {
  value = aws_instance.web.public_ip
}
output "db_private_ip" {
  value = aws_instance.db.private_ip
}
output "nat_gateway_eip" {
  value = aws_eip.nat_eip.public_ip
}
