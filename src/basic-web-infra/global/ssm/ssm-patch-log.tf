resource "aws_s3_bucket" "ssm_patch_log" {
  bucket = "ce-hiring-ssm-patch-log-store"

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
    Name             = "SSM Patch Logs"
    Environment      = "Production"
  })
}


resource "aws_s3_bucket_server_side_encryption_configuration" "ssm_patch_log" {
  bucket = aws_s3_bucket.ssm_patch_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "ssm_patch_log" {
  bucket = aws_s3_bucket.ssm_patch_log.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "ssm_patch_log" {
  bucket = aws_s3_bucket.ssm_patch_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "ssm_patch_log_policy" {
  name        = "AllowWriteToS3LogBucket"
  description = "Allows SSM to write to the ssm log bucket"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*Object"
          ],
          "Resource" : [
            aws_s3_bucket.ssm_patch_log.arn
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ssm_patch_log_policy_attachment" {
  role       = aws_iam_role.ssm_maintenance_window.name
  policy_arn = aws_iam_policy.ssm_patch_log_policy.arn
}
