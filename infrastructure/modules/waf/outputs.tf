# Regional Web ACLs (ALB/API Gateway-attachable)
output "web_acl_default_regional_arn" {
  description = "The ARN of the regional web ACL allowing all traffic which uses the AWS Managed Common Rule Set"
  value       = aws_wafv2_web_acl.regional_default.arn
}
