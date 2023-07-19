#https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html


resource "aws_config_config_rule" "ec2_volume_inuse_check" {
  name = "ec2_volume_inuse_check"

  source {
    owner             = "AWS"
    source_identifier = "EC2_VOLUME_INUSE_CHECK"
  }
}

resource "aws_config_config_rule" "eip_attached" {
  name = "eip_attached"

  source {
    owner             = "AWS"
    source_identifier = "EIP_ATTACHED"
  }
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name = "encrypted_volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
}

resource "aws_config_config_rule" "incoming_ssh_disabled" {
  name = "incoming_ssh_disabled"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
}

resource "aws_config_config_rule" "cloud_trail_enabled" {
  name = "cloud_trail_enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  input_parameters = <<EOF
{
  "s3BucketName": "ce-hiring-cloudtrail"
}
EOF
}

resource "aws_config_config_rule" "cloudwatch_alarm_action_check" {
  name = "cloudwatch_alarm_action_check"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDWATCH_ALARM_ACTION_CHECK"
  }

  input_parameters = <<EOF
{
  "alarmActionRequired" : "true",
  "insufficientDataActionRequired" : "false",
  "okActionRequired" : "false"
}
EOF
}

resource "aws_config_config_rule" "iam_group_has_users_check" {
  name = "iam_group_has_users_check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_GROUP_HAS_USERS_CHECK"
  }
}

//see https://docs.aws.amazon.com/config/latest/developerguide/iam-password-policy.html
resource "aws_config_config_rule" "iam_password_policy" {
  name = "iam_password_policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = <<EOF
{
  "RequireUppercaseCharacters" : "true",
  "RequireLowercaseCharacters" : "true",
  "RequireSymbols" : "true",
  "RequireNumbers" : "true",
  "MinimumPasswordLength" : "20",
  "PasswordReusePrevention" : "24",
  "MaxPasswordAge" : "90"
}
EOF
}

resource "aws_config_config_rule" "iam_user_group_membership_check" {
  name = "iam_user_group_membership_check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_GROUP_MEMBERSHIP_CHECK"
  }

  input_parameters = <<EOF
{
  "groupNames" : "readonly_users"
}
EOF
}

resource "aws_config_config_rule" "iam_user_no_policies_check" {
  name = "iam_user_no_policies_check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_NO_POLICIES_CHECK"
  }
}

resource "aws_config_config_rule" "root_account_mfa_enabled" {
  name = "root_account_mfa_enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "s3_bucket_public_read_prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  name = "s3_bucket_public_write_prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
}

resource "aws_config_config_rule" "s3_bucket_ssl_requests_only" {
  name = "s3_bucket_ssl_requests_only"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }
}

resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "s3_bucket_server_side_encryption_enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3_bucket_versioning_enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
}

resource "aws_config_config_rule" "ebs_optimized_instance" {
  name = "ebs_optimized_instance"

  source {
    owner             = "AWS"
    source_identifier = "EBS_OPTIMIZED_INSTANCE"
  }
}

resource "aws_config_config_rule" "required_tags" {
  name = "required_tags"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
  input_parameters = <<EOF
{
  "tag1Key" : "created_by",
  "tag1Value" : "terraform",
  "tag2Key" : "cost_center",
  "tag3Key" : "project"
}
EOF
}
