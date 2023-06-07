resource "aws_sns_topic" "codebuild_notifications" {
  name = "codebuild_notifications"
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
  policy = data.aws_iam_policy.sns_email_policy.json
}
