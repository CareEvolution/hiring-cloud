resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "${var.deployment_short_name}-${var.deployment_role}-loadbalancer"
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_acl" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.bucket
  policy = <<POLICY
{
    "Version" : "2012-10-17",
    "Id" : "LoadBalancerLogsPolicy",
    "Statement" : [
      {
        "Sid" : "AllowRootWriteAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${data.aws_elb_service_account.main.arn}"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.logging_bucket.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
}
POLICY
}
