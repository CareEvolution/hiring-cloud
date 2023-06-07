resource "aws_ssm_patch_baseline" "windows_defender" {
  name             = "ce-windows-defender-definition-updates"
  description      = "Baseline for updating windows defender definitions"
  operating_system = "WINDOWS"

  #Windows defender updates
  approval_rule {
    approve_after_days = 0
    compliance_level   = "INFORMATIONAL"

    patch_filter {
      key = "PATCH_SET"
      values = [
        "OS"
      ]
    }

    patch_filter {
      key = "PRODUCT"
      values = [
        "MicrosoftDefenderAntivirus"
      ]
    }
    patch_filter {
      key = "CLASSIFICATION"
      values = [
        "*"
      ]
    }

    patch_filter {
      key = "MSRC_SEVERITY"
      values = [
        "*"
      ]
    }
  }

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
    OS               = "Windows"
    Environment      = "Production"
  })
}


resource "aws_ssm_patch_group" "windows_defender" {
  baseline_id = aws_ssm_patch_baseline.windows_defender.id
  patch_group = "Windows Defender"
}

resource "aws_ssm_maintenance_window" "windows_defender" {
  name              = "WindowsDefenderDefinitionUpdates"
  schedule          = "rate(2 hours)"
  schedule_timezone = "America/Detroit"
  duration          = 3
  cutoff            = 1

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
  })
}

resource "aws_ssm_maintenance_window_target" "windows_defender" {
  name          = "AllWindowsInstances"
  window_id     = aws_ssm_maintenance_window.windows_defender.id
  description   = "Update all windows servers with windows defender."
  resource_type = "INSTANCE"

  targets {
    key = "tag-key"
    values = [
      "Name"
    ]
  }
}

resource "aws_ssm_maintenance_window_task" "windows_defender" {
  name             = "AutomaticReboot"
  max_concurrency  = 5
  max_errors       = 0
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  window_id        = aws_ssm_maintenance_window.windows_defender.id
  service_role_arn = aws_iam_role.ssm_maintenance_window.arn

  targets {
    key = "WindowTargetIds"
    values = [
      aws_ssm_maintenance_window_target.windows_defender.id,
    ]
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket     = aws_s3_bucket.ssm_patch_log.bucket
      output_s3_key_prefix = "Servers/WindowsDefender"
      timeout_seconds      = 600

      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["NoReboot"]
      }
    }
  }
}