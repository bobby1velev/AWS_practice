resource "aws_s3_bucket" "bucket" {
  bucket = "flutter-s3-test-bucket-2023-05-26"
  tags = {
    Name = "S3Bucket"
  }
}