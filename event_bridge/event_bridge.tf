# Attach a policy to the EventBridge role
resource "aws_iam_role_policy_attachment" "eventbridge_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}

# Create the EventBridge rule
resource "aws_cloudwatch_event_rule" "time_based_rule" {
  name                = "time-based-rule"
  description         = "Triggered by a time-based schedule"
  schedule_expression = "cron(0 20 * * ? *)"

  # Event pattern for CodeBuild project starts
  event_pattern = <<EOF
{
  "source": ["aws.codebuild"],
  "detail-type": ["CodeBuild Build State Change"],
  "detail": {
    "build-status": ["nuke_lol"]
  }
}
EOF
}

# Create a target to start the CodeBuild project
resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.time_based_rule.name
  target_id = "start-codebuild"
  arn       = aws_codebuild_project.nuke-all.arn
  role_arn  = aws_iam_role.codebuild_role.arn
}

# Associate the IAM role with the EventBridge rule (we need to insert association here)
resource "aws_cloudwatch_event_permission" "permission" {
  statement_id = "eventbridge-start-codebuild"
  principal    = "*"
}

