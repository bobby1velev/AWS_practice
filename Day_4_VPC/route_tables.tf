# Create routing tables
resource "aws_route_table" "public_rt1" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "PublicRouteTable"  
  }
}

resource "aws_route_table" "public_rt2" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "PublicRouteTable"  
  }
}

resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "PrivateRouteTable"  
  }
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "PrivateRouteTable"  
  }
}


# Private and public routes creation
resource "aws_route" "public_route1" {
  route_table_id         = aws_route_table.public_rt1.id
  destination_cidr_block = "0.0.0.0/0"  
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route" "public_route2" {
  route_table_id         = aws_route_table.public_rt2.id
  destination_cidr_block = "0.0.0.0/0"  
  gateway_id             = aws_internet_gateway.my_igw.id
}


resource "aws_route" "private_route1" {
  route_table_id            = aws_route_table.private_rt1.id
  destination_cidr_block    = "0.0.0.0/0" 
  nat_gateway_id            = aws_nat_gateway.my_nat_gateway1.id 
}

resource "aws_route" "private_route2" {
  route_table_id            = aws_route_table.private_rt2.id
  destination_cidr_block    = "0.0.0.0/0" 
  nat_gateway_id            = aws_nat_gateway.my_nat_gateway2.id 
}

# Association
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_rt1.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_rt2.id
}

resource "aws_route_table_association" "private_subnet3_association" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "private_subnet4_association" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.private_rt2.id
}
