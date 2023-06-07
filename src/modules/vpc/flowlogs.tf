resource "aws_s3_bucket" "flowlogs_bucket" {
  bucket        = "${var.deployment_short_name}-${var.deployment_role}-flowlogs"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "flowlogs_bucket" {
  bucket = aws_s3_bucket.flowlogs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "flowlogs_bucket" {
  bucket = aws_s3_bucket.flowlogs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flowlogs_bucket" {
  bucket = aws_s3_bucket.flowlogs_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_role" "flowlogs_cloudwatch" {
  name = "FlowLogsCloudWatch${title(var.deployment_role)}"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "vpc-flow-logs.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy" "flowlogs_cloudwatch" {
  name = "VPCFlowLogs"
  role = aws_iam_role.flowlogs_cloudwatch.name
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "logs:PutLogEvents",
            "logs:DescribeLogStreams",
            "logs:DescribeLogGroups",
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_flow_log" "all" {
  log_destination      = aws_s3_bucket.flowlogs_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
}

resource "aws_flow_log" "all_cloudwatch" {
  iam_role_arn    = aws_iam_role.flowlogs_cloudwatch.arn
  log_destination = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:FlowLogs"
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}