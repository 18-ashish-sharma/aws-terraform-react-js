variable "app_name" {
  description = "Short application name used in resource names (lowercase letters, digits and hyphens, 3-30 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.app_name))
    error_message = "app_name must be 3-30 chars of lowercase letters, digits and hyphens, and must not start or end with a hyphen."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "price_class" {
  description = "CloudFront price class. PriceClass_200 includes India and most of Asia and Europe; PriceClass_All adds South America and Australia."
  type        = string
  default     = "PriceClass_200"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be PriceClass_100, PriceClass_200 or PriceClass_All."
  }
}

variable "noncurrent_version_retention_days" {
  description = "Days to keep previous versions of objects in the bucket (lets you roll back a bad deploy) before they expire."
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_retention_days >= 1
    error_message = "noncurrent_version_retention_days must be at least 1."
  }
}

variable "force_destroy" {
  description = "Allow 'terraform destroy' to delete the bucket even when it still holds objects. Keep false outside throwaway environments."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags for every resource in the module."
  type        = map(string)
  default     = {}
}
