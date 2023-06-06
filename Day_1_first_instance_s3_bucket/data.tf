data "aws_iam_policy_document" "permissions_rights" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:Describe",
      "s3:List*"
    ]

resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.bucket.id}"    // we do this because "describe" action and "to do" action 
    ]
  }
}

data "aws_iam_policy_document" "assumed" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
        type = "AWS"
        identifiers = ["arn:aws:sts::778110084502:assumed-role/AWSReservedSSO_AWSAdministratorAccessLockedTags_a904a2f85c4d6cb3/borislav_velev@flutterint.com"]
    }   
  }
}
