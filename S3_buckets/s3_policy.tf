resource "aws_s3_bucket_policy" "my_policy" {
  bucket = aws_s3_bucket.bobby-test-bucket01.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": {
            "AWS": "arn:aws:sts::151371571764:assumed-role/AWSReservedSSO_AWSAdministratorAccessLockedTags_8809d5459337aa5d/ivan_piyvikov@flutterint.com"},
            "Action": [ "s3:GetObject",
                        "s3:ListBucket",
                        "s3:PutObject"
                      ],
            "Resource": [ "arn:aws:s3:::bobby-test-bucket01/*",
                          "arn:aws:s3:::bobby-test-bucket01"
                        ]
        }
    ]
}
POLICY
}