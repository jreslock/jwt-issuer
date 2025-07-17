# Web ACL that uses the AWS Managed Common Rule Set
# Allow all traffic unless blocked by a rule
resource "aws_wafv2_web_acl" "regional_default" {
  name        = "${var.name}-regional"
  description = "Regional Web ACL using the AWS Managed Common Rule Set"
  scope       = local.regional_scope

  default_action {
    allow {}
  }


  rule {
    name     = "common-rule-set"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.aws_waf_managed_common_rule_set_name
        vendor_name = "AWS"
        version     = "Version_${var.aws_waf_managed_common_rule_set_version}"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "aws-waf-regional-default-common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "admin-protection"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.aws_waf_managed_admin_protection_name
        vendor_name = "AWS"
        # This rule set does not support versioning

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "AdminProtection_URIPATH"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "aws-waf-regional-default-admin-protection"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "known-bad-inputs"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.aws_waf_managed_known_bad_inputs_name
        vendor_name = "AWS"
        version     = "Version_${var.aws_waf_managed_known_bad_inputs_rule_set_version}"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "aws-waf-regional-default-known-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-regional"
  })

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = "aws-waf-regional-default-aggregate"
    sampled_requests_enabled   = true
  }
}
