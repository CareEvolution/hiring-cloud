
resource "aws_s3_bucket" "ssm_packages" {
  bucket = "ce-hiring-ssm-packages-store"

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
    Name             = "SSM Packages"
    Environment      = "Production"
  })
}

resource "aws_s3_bucket_versioning" "ssm_packages" {
  bucket = aws_s3_bucket.ssm_packages.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ssm_packages" {
  bucket = aws_s3_bucket.ssm_packages.bucket

  rule {
    id     = "DeleteIncompleteMultipartUploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 5
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.ssm_packages
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssm_packages" {
  bucket = aws_s3_bucket.ssm_packages.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "ssm_packages" {
  bucket = aws_s3_bucket.ssm_packages.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "ssm_packages" {
  bucket = aws_s3_bucket.ssm_packages.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
