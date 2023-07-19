resource "aws_iam_policy" "allow_automation_access" {
  name        = "AllowAutomationAccess"
  description = "Allows limited access to specific resources needed for automation."
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowSSMParameterStoreAccess",
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter"
          ],
          "Resource" : [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
          ]
        },
        {
          "Sid" : "AllowSSMParamterDecryption",
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt"
          ],
          "Resource" : [
            "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/ssm"
          ]
        },
        {
          "Sid" : "AllowEC2ReadOnlyLimitedAccess",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeTags",
            "ec2:DescribeInstances"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Sid" : "AllowSSMArtifiactAccess",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:GetEncryptionConfiguration"
          ],
          "Resource" : [
            "${aws_s3_bucket.ssm_artifacts.arn}/*",
            "${aws_s3_bucket.ssm_artifacts.arn}"
          ]
        }
      ]
  })
}