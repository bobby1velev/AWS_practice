resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  

  tags = {
    Name = "my_terraform_vpc" 
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"  
  availability_zone       = "eu-west-1a"  

  tags = {
    Name = "Subnet1_a"  
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24" 
  availability_zone       = "eu-west-1b"  

  tags = {
    Name = "Subnet2_b" 
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"  
  availability_zone       = "eu-west-1a"  


  tags = {
    Name = "Subnet3_a"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-1b" 

  tags = {
    Name = "Subnet4_b"  
  }
}
