data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


data "aws_caller_identity" "ops" {
  provider = aws.admin
}

resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length        = 20
  max_password_age               = 90
  password_reuse_prevention      = 24
  hard_expiry                    = false
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_policy" "require_mfa" {
  name = "RequireMFA"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowViewAccountInfo",
          "Effect" : "Allow",
          "Action" : [
            "iam:GetAccountPasswordPolicy",
            "iam:GetAccountSummary",
            "iam:ListVirtualMFADevices"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "AllowManageOwnPasswords",
          "Effect" : "Allow",
          "Action" : [
            "iam:ChangePassword",
            "iam:GetUser"
          ],
          "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
        },
        {
          "Sid" : "AllowManageOwnAccessKeys",
          "Effect" : "Allow",
          "Action" : [
            "iam:CreateAccessKey",
            "iam:DeleteAccessKey",
            "iam:ListAccessKeys",
            "iam:UpdateAccessKey"
          ],
          "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
        },
        {
          "Sid" : "AllowManageOwnVirtualMFADevice",
          "Effect" : "Allow",
          "Action" : [
            "iam:CreateVirtualMFADevice",
            "iam:DeleteVirtualMFADevice"
          ],
          "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}"
        },
        {
          "Sid" : "AllowManageOwnUserMFA",
          "Effect" : "Allow",
          "Action" : [
            "iam:DeactivateMFADevice",
            "iam:EnableMFADevice",
            "iam:ListMFADevices",
            "iam:ResyncMFADevice"
          ],
          "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
        },
        {
          "Sid" : "DenyAllExceptListedIfNoMFA",
          "Effect" : "Deny",
          "NotAction" : [
            "iam:CreateVirtualMFADevice",
            "iam:DeleteVirtualMFADevice",
            "iam:EnableMFADevice",
            "iam:GetUser",
            "iam:ListMFADevices",
            "iam:ListVirtualMFADevices",
            "iam:ResyncMFADevice",
            "sts:GetSessionToken",
            "sts:AssumeRole"
          ],
          "Resource" : "*",
          "Condition" : {
            "BoolIfExists" : {
              "aws:MultiFactorAuthPresent" : "false"
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "require_mfa" {
  role       = "OrganizationAccountAccessRole"
  policy_arn = aws_iam_policy.require_mfa.arn
}

resource "aws_iam_role_policy_attachment" "aws_support_access" {
  role       = "OrganizationAccountAccessRole"
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}