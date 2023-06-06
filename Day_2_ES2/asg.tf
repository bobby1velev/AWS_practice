# Create Autoscaling group
resource "aws_autoscaling_group" "example" {
  name                = "name"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.my_subnets.ids
  
}
