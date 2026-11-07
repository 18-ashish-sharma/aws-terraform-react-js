output "bucket_name" {
  description = "S3 bucket to upload the build to."
  value       = module.static_site.bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID, for cache invalidation."
  value       = module.static_site.cloudfront_distribution_id
}

output "website_url" {
  description = "HTTPS URL of the site."
  value       = module.static_site.website_url
}
