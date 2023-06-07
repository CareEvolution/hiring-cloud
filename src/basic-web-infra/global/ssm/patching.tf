#https://docs.microsoft.com/en-us/troubleshoot/windows-client/deployment/standard-terminology-software-updates

resource "aws_ssm_patch_baseline" "windows_patching_baseline" {
  name             = "ce-windows-baseline"
  description      = "Patching baseline for windows servers"
  operating_system = "WINDOWS"

  # Critical Stability and security related OS patches
  approval_rule {
    approve_after_days = 3
    compliance_level   = "CRITICAL"

    patch_filter {
      key = "PATCH_SET"
      values = [
        "OS"
      ]
    }

    patch_filter {
      key = "PRODUCT"
      values = [
        "*"
      ]
    }
    patch_filter {
      key = "CLASSIFICATION"
      values = [
        "CriticalUpdates",
        "SecurityUpdates"
      ]
    }

    patch_filter {
      key = "MSRC_SEVERITY"
      values = [
        "Critical",
        "Important"
      ]
    }
  }

  # All other OS updates
  approval_rule {
    approve_after_days = 14
    compliance_level   = "LOW"

    patch_filter {
      key = "PATCH_SET"
      values = [
        "OS"
      ]
    }

    patch_filter {
      key = "PRODUCT"
      values = [
        "*"
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
        "Low",
        "Moderate",
        "Unspecified"
      ]
    }
  }

  # All application updates
  approval_rule {
    approve_after_days = 3
    compliance_level   = "LOW"

    patch_filter {
      key = "PATCH_SET"
      values = [
        "APPLICATION"
      ]
    }

    patch_filter {
      key = "PRODUCT"
      values = [
        "*"
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

resource "aws_ssm_patch_baseline" "amazon_linux_patching_baseline" {
  name             = "ce-amazon-linux-baseline"
  description      = "SSM Patch Baseline for amazon linux servers"
  operating_system = "AMAZON_LINUX"

  approval_rule {
    approve_after_days = 3
    compliance_level   = "CRITICAL"
    patch_filter {
      key = "CLASSIFICATION"
      values = [
        "Security", "Recommended"
      ]
    }
    patch_filter {
      key = "SEVERITY"
      values = [
        "Critical",
        "Important"
      ]
    }
  }

  approval_rule {
    approve_after_days = 3
    compliance_level   = "LOW"
    patch_filter {
      key = "CLASSIFICATION"
      values = [
        "Security",
        "Recommended",
        "Newpackage",
        "Enhancement",
        "Bugfix"
      ]
    }
  }

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
    OS               = "Amazon Linux"
    Environment      = "Production"
  })
}

resource "aws_ssm_patch_baseline" "amazon_linux2_patching_baseline" {
  name             = "ce-amazon-linux2-baseline"
  description      = "SSM Patch Baseline for amazon linux servers"
  operating_system = "AMAZON_LINUX_2"

  approval_rule {
    approve_after_days = 3
    compliance_level   = "CRITICAL"
    patch_filter {
      key = "CLASSIFICATION"
      values = [
        "Security", "Recommended"
      ]
    }
    patch_filter {
      key = "SEVERITY"
      values = [
        "Critical",
        "Important"
      ]
    }
  }

  approval_rule {
    approve_after_days = 3
    compliance_level   = "LOW"
    patch_filter {
      key = "CLASSIFICATION"
      values = [
        "Security",
        "Recommended",
        "Newpackage",
        "Enhancement",
        "Bugfix"
      ]
    }
  }

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
    OS               = "Amazon Linux"
    Environment      = "Production"
  })
}

resource "aws_ssm_patch_group" "windows_automatic_reboot" {
  baseline_id = aws_ssm_patch_baseline.windows_patching_baseline.id
  patch_group = "Windows Automatic Reboot"
}

resource "aws_ssm_patch_group" "primary_domain_controller" {
  baseline_id = aws_ssm_patch_baseline.windows_patching_baseline.id
  patch_group = "Primary Domain Controller"
}

resource "aws_ssm_patch_group" "patch_server" {
  baseline_id = aws_ssm_patch_baseline.windows_patching_baseline.id
  patch_group = "Patch Server"
}

resource "aws_ssm_patch_group" "aws_linux_automatic_reboot" {
  baseline_id = aws_ssm_patch_baseline.amazon_linux_patching_baseline.id
  patch_group = "AWS Linux Automatic Reboot"
}

resource "aws_ssm_patch_group" "aws_linux2_automatic_reboot" {
  baseline_id = aws_ssm_patch_baseline.amazon_linux2_patching_baseline.id
  patch_group = "AWS Linux 2 Automatic Reboot"
}

resource "aws_ssm_maintenance_window" "servers" {
  name              = "PatchAllEC2Instances"
  schedule          = "cron(0 4 * * ? *)"
  schedule_timezone = "America/Detroit"
  duration          = 3
  cutoff            = 1

  tags = merge(var.default_tags, {
    ce_resource_path = "/HIRING/GLOBAL/SSM"
  })
}

resource "aws_ssm_maintenance_window_target" "domain_controller" {
  name          = "WindowsPrimaryDomainController"
  window_id     = aws_ssm_maintenance_window.servers.id
  description   = "Patch the primary domain controller independently so we don't accidentally take the domain offline."
  resource_type = "INSTANCE"

  targets {
    key = "tag:Patch Group"
    values = [
      aws_ssm_patch_group.primary_domain_controller.patch_group
    ]
  }
}

resource "aws_ssm_maintenance_window_target" "patch_server" {
  name          = "WindowsPatchServer"
  window_id     = aws_ssm_maintenance_window.servers.id
  description   = "Patch the patch server so we don't accidentally break patching for other instances."
  resource_type = "INSTANCE"

  targets {
    key = "tag:Patch Group"
    values = [
      aws_ssm_patch_group.patch_server.patch_group
    ]
  }
}

resource "aws_ssm_maintenance_window_target" "windows_automatic_reboot" {
  name          = "WindowsAutomaticReboot"
  window_id     = aws_ssm_maintenance_window.servers.id
  description   = "Targets to install updates with a reboot reboot if necessary."
  resource_type = "INSTANCE"

  targets {
    key = "tag:Patch Group"
    values = [
      aws_ssm_patch_group.windows_automatic_reboot.patch_group
    ]
  }
}

resource "aws_ssm_maintenance_window_target" "linux_automatic_reboot" {
  name          = "LinuxAutomaticReboot"
  window_id     = aws_ssm_maintenance_window.servers.id
  description   = "Targets to install updates with a reboot if necessary."
  resource_type = "INSTANCE"

  targets {
    key = "tag:Patch Group"
    values = [
      aws_ssm_patch_group.aws_linux_automatic_reboot.patch_group,
      aws_ssm_patch_group.aws_linux2_automatic_reboot.patch_group
    ]
  }
}

resource "aws_ssm_maintenance_window_task" "automatic_reboot" {
  name             = "AutomaticReboot"
  max_concurrency  = 5
  max_errors       = 0
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  window_id        = aws_ssm_maintenance_window.servers.id
  service_role_arn = aws_iam_role.ssm_maintenance_window.arn

  targets {
    key = "WindowTargetIds"
    values = [
      #If a single maintenance window task is registered with multiple targets,
      # its task invocations occur sequentially and not in parallel.
      # We use the sequential behavior ensure domain controller and patch server get patched after everything else.
      aws_ssm_maintenance_window_target.windows_automatic_reboot.id,
      aws_ssm_maintenance_window_target.linux_automatic_reboot.id,
      aws_ssm_maintenance_window_target.patch_server.id,
      aws_ssm_maintenance_window_target.domain_controller.id,
    ]
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket     = aws_s3_bucket.ssm_patch_log.bucket
      output_s3_key_prefix = "Servers/AutomaticReboot"
      timeout_seconds      = 600

      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }
}