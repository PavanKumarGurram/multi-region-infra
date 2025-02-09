# WAF Web ACL for CloudFront
resource "aws_wafv2_web_acl" "cloudfront" {
  provider    = aws.us-east-1  # WAF for CloudFront must be in us-east-1
  name        = "${var.environment}-cloudfront-acl"
  description = "WAF Web ACL for CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # AWS Managed Rules
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled  = true
    }
  }

  # Rate Limiting Rule
  rule {
    name     = "RateLimitRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "RateLimitRuleMetric"
      sampled_requests_enabled  = true
    }
  }

  # Geo Blocking Rule
  rule {
    name     = "GeoBlockRule"
    priority = 3

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = var.blocked_countries
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "GeoBlockRuleMetric"
      sampled_requests_enabled  = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "CloudFrontWebACLMetric"
    sampled_requests_enabled  = true
  }

  tags = var.tags
}

# Shield Advanced Protection
resource "aws_shield_protection" "cloudfront" {
  name         = "${var.environment}-cloudfront-protection"
  resource_arn = aws_cloudfront_distribution.main.arn

  tags = var.tags
}