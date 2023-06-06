data "aws_vpc" "vpc" {
  filter{
    name = "vpc-id"
    values = ["vpc-0ca4ab763b222a50c"]
  }
}

data "aws_subnets" "my_subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}