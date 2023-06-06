  resource "aws_s3_bucket_public_access_block" "my_block_list" {
  bucket = aws_s3_bucket.bobby-test-bucket01.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
