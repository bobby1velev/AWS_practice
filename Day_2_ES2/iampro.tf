resource "aws_iam_instance_profile" "new_profile" {
  name = "new-profile"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "test_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy" "example" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  name = "policy-attachment"
  roles       = [aws_iam_role.role.name]
  policy_arn = data.aws_iam_policy.example.arn
}