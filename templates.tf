############################################
# Auto scaling group files
############################################

# Launch template

resource "aws_launch_template" "first_template" {
  name_prefix            = "terraform"
  image_id               = data.aws_ami.latest_amazon_linux.image_id
  instance_type          = "t2.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
  }
  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    EOF
  )
}

# If we use variable for image name

variable "image_name" {
  default     = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"
  type        = string
  description = "Amazon linux image name"
}

# Autoscaling group settings

resource "aws_autoscaling_group" "bar" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.default_vpc_subnets.ids

  launch_template {
    id      = aws_launch_template.first_template.id
    version = "$Latest"
  }
}

############################################
# Security group that allows specific traffic
############################################

resource "aws_security_group" "allow_http" {
  name   = "first-lab"
  vpc_id = data.aws_vpc.default_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# IAM role for SSM
############################################

resource "aws_iam_role" "ssm_mgmt" {
  name = "ssm-mgmt"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ssm_mgmt_attachment" {
  role       = aws_iam_role.ssm_mgmt.id
  policy_arn = var.policy_arn
}

variable "policy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.ssm_mgmt.name
}

############################################
# Nat creation
############################################

resource "aws_nat_gateway" "nat1" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.subnet1.id
  allocation_id     = aws_eip.eip1.id

  tags = {
    Name = "terraform-nat1"
  }
}

resource "aws_nat_gateway" "nat2" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.subnet2.id
  allocation_id     = aws_eip.eip2.id


  tags = {
    Name = "terraform-nat2"
  }
}

resource "aws_eip" "eip1" {
  domain = "vpc"
}

resource "aws_eip" "eip2" {
  domain = "vpc"
}

############################################
# VPC creation
############################################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name = "terraform-vpc"
  }
}

############################################
# Internet gateway creation
############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = "terraform-igw"
  }
}

############################################
# Autoscaling group for vpc creation
############################################

resource "aws_launch_template" "first_template" {
  name_prefix            = "terraform"
  image_id               = data.aws_ami.latest_amazon_linux.image_id
  instance_type          = "t2.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  iam_instance_profile {
    name = data.aws_iam_instance_profile.example.name
  }
  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    sudo rm /usr/share/nginx/html/index.html
    echo '<html><style>body {font-size: 20px;}</style><body><p>Server 2 Ace!! &#x1F0A1;</p></body></html>' | sudo tee /usr/share/nginx/html/index.html
    EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = data.aws_subnets.terraform_vpc_subnets.ids
  target_group_arns   = [aws_lb_target_group.lb_tg.arn]

  launch_template {
    id      = aws_launch_template.first_template.id
    version = "$Latest"
  }
}

############################################
# Loadbalancer for vpc creation
############################################

resource "aws_lb" "alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "terraform-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "nginx-lbl" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

############################################
# Routing table creation
############################################

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-rt1"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-rt2"
  }
}


resource "aws_route_table" "rt3" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "terraform-rt3"
  }
  lifecycle {
    ignore_changes = [route]
  }
}


resource "aws_route_table" "rt4" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "terraform-rt4"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt3.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.rt4.id
}

############################################
# Security group for vpc creation
############################################

resource "aws_security_group" "allow_http" {
  name   = "first-lab"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["94.156.24.20/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Subnets for vpc creation
############################################

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "terraform-subnet-1-public"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "terraform-subnet-2-public"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "terraform-subnet-3-private"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "terraform-subnet-4-private"
  }
}

############################################
# SNS
############################################

resource "aws_sns_topic" "codebuild_notifications" {
  name = "codebuild-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.codebuild_notifications.arn
  protocol  = "email"
  endpoint  = "dimitar_manov@flutterint.com" # Update with your email address
}

# Create a lifecycle event trigger for CodeBuild project state changes
resource "aws_cloudwatch_event_rule" "project_state_rule" {
  name          = "codebuild-project-state-rule"
  description   = "Event rule for CodeBuild project state changes"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.codebuild"
  ],
  "detail-type": [
    "CodeBuild Build State Change"
  ],
  "detail": {
    "project-name": [
      "${aws_codebuild_project.nuke-all.name}"
    ]
  }
}
PATTERN
}

# Configure SNS target for CodeBuild project state change events
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.project_state_rule.name
  arn       = aws_sns_topic.codebuild_notifications.arn
  target_id = "sns-target"
}

data "aws_iam_policy" "sns_email_policy" {
  name        = "sns-email-policy"
  description = "Allows SNS to send email notifications"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "${aws_sns_topic.codebuild_notifications.arn}"
    }
  ]
}
POLICY
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.codebuild_notifications.arn
  policy = data.aws_iam_policy.sns_email_policy.policy
}
