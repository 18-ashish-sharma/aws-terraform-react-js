variable "aws_region" {
  description = "AWS region for the S3 bucket. CloudFront itself is global."
  type        = string
  default     = "ap-south-1"
}

variable "app_name" {
  description = "Short application name used in resource names."
  type        = string
  default     = "react-app"
}

variable "price_class" {
  description = "CloudFront price class (PriceClass_100, PriceClass_200 or PriceClass_All)."
  type        = string
  default     = "PriceClass_200"
}
