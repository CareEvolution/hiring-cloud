data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "default_tags" {
  type = map(any)
  default = {
    created_by  = "terraform",
    project     = "ssm"
    cost_center = "global"
  }
}

resource "aws_iam_role" "ssm_maintenance_window" {
  name = "ssm-maintenance-window"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowAssumeRole",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : [
              "ec2.amazonaws.com",
              "ssm.amazonaws.com"
            ]
          },
          "Effect" : "Allow"
        }
      ]
    }
  )

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_maintenance_window" {
  role       = aws_iam_role.ssm_maintenance_window.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}