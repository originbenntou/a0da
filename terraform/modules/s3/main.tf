resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "Frontend Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = var.oai_arn
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}
