# Allocate Elastic IP for NAT gateway
resource "aws_eip" "nat_eip1" {
  domain = "vpc"
  }

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
  }

# Create NAT gateway
resource "aws_nat_gateway" "my_nat_gateway1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.subnet1.id 
}

resource "aws_nat_gateway" "my_nat_gateway2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.subnet2.id 
}