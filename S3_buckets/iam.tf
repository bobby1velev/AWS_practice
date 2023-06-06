#resource "aws_iam_role" "s3_role" {
#  name = "s3_role"
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Action = ["sts:AssumeRole"]
#        Principal = {
#          Service = "s3.amazonaws.com"
#        }
#      }
#    ]
#  })
#}
#
#resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
#  role       = aws_iam_role.s3_role.id
#  policy_arn = var.policy_arn
#
#}
