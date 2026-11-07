# Private bucket. Only CloudFront (through Origin Access Control) can read objects;
# nobody reaches the bucket directly, and there is no S3 static-website endpoint.
resource "aws_s3_bucket" "app" {
  #checkov:skip=CKV_AWS_18:Access logs are taken at CloudFront, the only reader of this bucket.
  #checkov:skip=CKV_AWS_144:Build output is reproducible from git; cross-region replication is not worth the cost.
  #checkov:skip=CKV_AWS_145:SSE-S3 (AES-256). SSE-KMS would need the key policy to allow CloudFront and adds per-request KMS cost for public, non-sensitive files.
  #checkov:skip=CKV2_AWS_62:No consumer for object-created events.

  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.tags, { Name = local.bucket_name })
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Disables ACLs: the bucket owner owns every object, access is decided by policy only.
resource "aws_s3_bucket_ownership_controls" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versioning keeps the previous build after 'aws s3 sync --delete', so a bad deploy can be rolled back.
resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Old versions would otherwise pile up forever with every deploy.
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "expire-old-builds"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.app]
}

data "aws_iam_policy_document" "app" {
  # Only this CloudFront distribution may read objects.
  statement {
    sid       = "AllowCloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.app.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.app.arn]
    }
  }

  # Refuse any request that is not over TLS.
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "app" {
  bucket = aws_s3_bucket.app.id
  policy = data.aws_iam_policy_document.app.json

  # The public access block must exist first, or a policy change can race it.
  depends_on = [aws_s3_bucket_public_access_block.app]
}
