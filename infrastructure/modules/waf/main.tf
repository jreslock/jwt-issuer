/**
    * WAF
*
* This module creates a WAF for the jwt-issuer
* The WAF is used to protect the jwt-issuer from attacks
* The WAF is configured to allow traffic from the jwt-issuer
* The WAF is configured to block traffic from the jwt-issuer
*/

locals {
  aws_waf_managed_common_rule_set_name  = "AWSManagedRulesCommonRuleSet"
  aws_waf_managed_known_bad_inputs_name = "AWSManagedRulesKnownBadInputsRuleSet"
  aws_waf_managed_admin_protection_name = "AWSManagedRulesAdminProtectionRuleSet"
  regional_scope                        = "REGIONAL"
}
