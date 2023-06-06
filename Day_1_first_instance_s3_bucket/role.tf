resource "aws_iam_role" "random_role" {
  name = "test-role"
  assume_role_policy = data.aws_iam_policy_document.assumed.json
}
resource "aws_iam_role_policy" "random_role_policy_attachment" {
  name = "test-role-policy"
  policy = data.aws_iam_policy_document.permissions_rights.json
  role   = aws_iam_role.random_role.id
}