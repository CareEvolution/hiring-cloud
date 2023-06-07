resource "aws_s3_bucket" "ssm_artifacts" {
  bucket = "hiring-ssm-artifacts-store"

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM/S3"
  })
}

resource "aws_s3_bucket_cors_configuration" "ssm_artifacts" {
  bucket = aws_s3_bucket.ssm_artifacts.bucket

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssm_artifacts" {
  bucket = aws_s3_bucket.ssm_artifacts.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "ssm_artifacts" {
  bucket = aws_s3_bucket.ssm_artifacts.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "ssm_artifacts" {
  bucket = aws_s3_bucket.ssm_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}