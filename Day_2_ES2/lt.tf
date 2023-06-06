# Create Launch Template
resource "aws_launch_template" "example" {
  name          = "lunch-template-01"
  image_id      = data.aws_ami.ami_example.id
  instance_type = "t2.micro"


  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      encrypted = true
      volume_size = 20
    }
  }

  vpc_security_group_ids = [aws_security_group.test_group.id]

  user_data = filebase64("${path.module}/example.sh")

  iam_instance_profile {
    name = aws_iam_instance_profile.new_profile.name
  }
}



