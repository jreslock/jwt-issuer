variable "aws_waf_managed_common_rule_set_version" {
  description = "The version of the AWS WAF managed rule group to use"
  type        = string
  default     = "1.15"
}

variable "aws_waf_managed_known_bad_inputs_rule_set_version" {
  description = "The version of the AWS WAF managed rule group to use"
  type        = string
  default     = "1.22"
}

variable "cloudwatch_logging_enabled" {
  description = "Whether to enable logging for the WAF"
  type        = bool
  default     = false
}

variable "cloudwatch_metrics_enabled" {
  description = "Whether to enable CloudWatch metrics for the WAF"
  type        = bool
  default     = false
}

variable "cloudwatch_retention_days" {
  description = "The number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "default_action" {
  description = "The default action to take for the WAF"
  type        = string
  default     = "allow"
}

variable "name" {
  description = "The name to use for resources created by this module"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
