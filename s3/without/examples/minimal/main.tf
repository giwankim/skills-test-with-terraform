module "s3_bucket" {
  source = "../.."

  name_prefix = var.name_prefix
}
