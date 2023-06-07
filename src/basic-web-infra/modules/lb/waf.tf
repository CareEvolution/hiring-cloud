resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "${var.deployment_short_name}-${var.deployment_role}-waf-acl"
  scope       = "REGIONAL"
  description = "Baseline wafv2 web acl"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.deployment_short_name}-${var.deployment_role}-waf-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 1
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
        excluded_rule {
          name = "AWSManagedIPReputationList"
        }

        excluded_rule {
          name = "AWSManagedIPReputationList_0000"
        }
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
        excluded_rule {
          name = "GenericRFI_BODY"
        }
        excluded_rule {
          name = "SizeConstraint_BODY"
        }
        excluded_rule {
          name = "SizeRestrictions_BODY"
        }

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "CrossSiteScripting_BODY"
        }
        excluded_rule {
          name = "SizeRestrictions_Cookie_HEADER"
        }
        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
        excluded_rule {
          name = "GenericLFI_BODY"
        }

        excluded_rule {
          name = "GenericRFI_QUERYARGUMENTS"
        }

        excluded_rule {
          name = "EC2MetaDataSSRF_BODY"
        }
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 4
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
        excluded_rule {
          name = "SQLi_BODY"
        }
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesWindowsRuleSet"
    priority = 5
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesWindowsRuleSet"
        excluded_rule {
          name = "PowerShellCommands_BODY"
        }
        excluded_rule {
          name = "PowerShellCommands_COOKIE"
        }
        excluded_rule {
          name = "PowerShellCommands_QUERYARGUMENTS"
        }
        excluded_rule {
          name = "WindowsShellCommands_BODY"
        }
        excluded_rule {
          name = "WindowsShellCommands_COOKIE"
        }
        excluded_rule {
          name = "WindowsShellCommands_QUERYARGUMENTS"
        }

      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesWindowsRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

