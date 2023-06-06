resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway" 
  }
}

# Attach igw to VPC
resource "aws_main_route_table_association" "my_vpc_igw_association" {
  vpc_id                  = aws_vpc.my_vpc.id
  route_table_id          = aws_vpc.my_vpc.default_route_table_id
  depends_on              = [aws_internet_gateway.my_igw]

  lifecycle {
    ignore_changes = [route_table_id]
  }
}