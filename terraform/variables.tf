variable "aws-region" {
  type = string
  description = "Region for AWS resources to be created"
  default = "eu-west-1"
}

variable "company" {
  type = string
  description = "My_company_name"
  default = "Tavern&Co"
}

variable "project" {
  type = string
  description = "project name for tagging"
  default = "Costas"
}

variable "vpc" {
type = string
description = "network resource"
default = "10.0.14.0/24"  
}

variable "subnet1" {
  type = string
  description = "Networking cidr_block subnet1"
  default = "10.0.14.0/25"
}