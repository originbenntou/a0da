data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.bucket_name}-cloudfront-logs"
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs]

  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "cloudfront_logs_policy" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontLogs",
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.cloudfront_logs.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.frontend_distribution.id}"
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 access"
}

resource "aws_cloudfront_response_headers_policy" "cors_policy" {
  name = "CORSPolicy"

  cors_config {
    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }
    access_control_allow_origins {
      items = ["*"]
    }
    access_control_allow_credentials = false
    origin_override                = true
  }
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = var.bucket_domain_name
    origin_id   = "S3-${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for frontend"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = "arn:aws:lambda:us-east-1:388450459156:function:a0demo-auth0-verifier:1"
      include_body = false
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors_policy.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  logging_config {
    bucket = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix = "cloudfront-logs/"
    include_cookies = false
  }

  tags = {
    Name        = "Frontend Distribution"
    Environment = var.environment
  }
}
