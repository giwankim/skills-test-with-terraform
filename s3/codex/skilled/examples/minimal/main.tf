terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = "replace-with-unique-minimal-bucket-name"
}

output "bucket_id" {
  description = "Created bucket ID."
  value       = module.s3_bucket.bucket_id
}
