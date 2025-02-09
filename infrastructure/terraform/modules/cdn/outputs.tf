output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = aws_route53_zone.main.zone_id
}

output "route53_name_servers" {
  description = "Name servers for the Route 53 zone"
  value       = aws_route53_zone.main.name_servers
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.cloudfront.arn
}

output "waf_web_acl_id" {
  description = "ID of the WAF web ACL"
  value       = aws_wafv2_web_acl.cloudfront.id
}