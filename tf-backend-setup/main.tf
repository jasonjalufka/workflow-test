terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.36.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
# svip4tfstate
resource "aws_s3_bucket" "state" {
  bucket = "svip4tfstate"

}

resource "aws_s3_bucket_acl" "state" {
  bucket = aws_s3_bucket.state.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "state_bucket" {
  value = aws_s3_bucket.state.bucket
}
