output "aws_instance_publicdns" {
  value = aws_instance.nginx1.public_dns
}