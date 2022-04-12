locals {
  s3_bucket_name = "my-react-app-${var.env}"
  s3_origin_id   = "S3-origin-my-react-app-${var.env}"

  tags = {
    env         = var.env,
    Application = "my-react-app"
  }
}