output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.frontend_distribution.domain_name
}

output "oai_arn" {
  value = aws_cloudfront_origin_access_identity.oai.iam_arn
}
