variable "policy_arn" {
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "image_name" {
  default     = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"
  type        = string
  description = "Amazon linux image name"
}

# variable "id_of_instance" {
#   default = aws_instance.instance_id

# }
