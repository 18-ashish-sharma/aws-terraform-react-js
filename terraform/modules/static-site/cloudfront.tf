# AWS-managed policies, looked up by name so the IDs are not magic strings.
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, X-XSS-Protection.
data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

# Origin Access Control: CloudFront signs every request to S3 with SigV4.
# It replaces the legacy Origin Access Identity (OAI).
resource "aws_cloudfront_origin_access_control" "app" {
  name                              = local.bucket_name
  description                       = "CloudFront access to ${local.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "app" {
  #checkov:skip=CKV_AWS_68:WAF costs about USD 5/month plus per-rule fees; not justified for a static demo site. Attach a web ACL via web_acl_id for production.
  #checkov:skip=CKV_AWS_86:Standard logging needs a separate log bucket with ACLs enabled; left out to keep the demo small. Enable logging_config for production.
  #checkov:skip=CKV_AWS_174:Uses the default *.cloudfront.net certificate, where AWS fixes the minimum protocol. With a custom domain set minimum_protocol_version = "TLSv1.2_2021".
  #checkov:skip=CKV2_AWS_42:Same reason: no custom domain, so no ACM certificate.
  #checkov:skip=CKV2_AWS_47:No WAF attached (see CKV_AWS_68).
  #checkov:skip=CKV_AWS_310:Single S3 origin; origin failover would need a replica bucket in a second region.
  #checkov:skip=CKV_AWS_374:The site is public; no geo restriction intended.

  comment             = local.name
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  price_class         = var.price_class
  default_root_object = "index.html"

  origin {
    origin_id                = local.origin_id
    domain_name              = aws_s3_bucket.app.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.app.id
  }

  # Hashed assets (static/js/main.abc123.js) are immutable, so cache them hard.
  default_cache_behavior {
    target_origin_id           = local.origin_id
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id
  }

  # index.html is never cached, so a new deploy is picked up without waiting for a TTL.
  ordered_cache_behavior {
    path_pattern               = "/index.html"
    target_origin_id           = local.origin_id
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id
  }

  # Single-page app routing: a deep link such as /about has no object in S3.
  # S3 answers 403 (CloudFront has no s3:ListBucket, so missing keys look forbidden),
  # and CloudFront serves index.html so React Router can render the route.
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.tags
}
