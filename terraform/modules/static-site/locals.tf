data "aws_caller_identity" "current" {}

locals {
  name = "${var.app_name}-${var.environment}"

  # S3 bucket names are global. The account ID keeps the name unique without a random suffix.
  bucket_name = "${local.name}-${data.aws_caller_identity.current.account_id}"
  origin_id   = "s3-${local.bucket_name}"

  tags = merge(var.tags, {
    Application = var.app_name
    Environment = var.environment
  })
}
