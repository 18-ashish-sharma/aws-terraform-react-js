output "bucket_name" {
  description = "S3 bucket holding the built React app (upload target for 'aws s3 sync')."
  value       = aws_s3_bucket.app.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.app.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for a manual invalidation; deploys do not need one because index.html is never cached)."
  value       = aws_cloudfront_distribution.app.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name, e.g. d1234abcd.cloudfront.net."
  value       = aws_cloudfront_distribution.app.domain_name
}

output "website_url" {
  description = "HTTPS URL of the site."
  value       = "https://${aws_cloudfront_distribution.app.domain_name}"
}
