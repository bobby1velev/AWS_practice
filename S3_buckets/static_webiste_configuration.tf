resource "aws_s3_bucket_website_configuration" "my_configuration" {
  bucket = aws_s3_bucket.bobby-test-bucket01.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}
