module "static_site" {
  source = "../../modules/static-site"

  app_name    = var.app_name
  environment = "dev"
  price_class = var.price_class

  # dev is disposable: allow 'terraform destroy' to empty the bucket.
  force_destroy = true
}
