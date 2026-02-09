module "s3_bucket" {
  source = "../../"

  bucket_prefix = "minimal-example-"

  tags = {
    Environment = "dev"
    Example     = "minimal"
  }
}
