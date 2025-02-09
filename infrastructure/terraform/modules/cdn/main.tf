locals {
  s3_origin_id = "${var.environment}-s3-origin"
  alb_origin_id = "${var.environment}-alb-origin"
}

# ACM Certificate for CloudFront
resource "aws_acm_certificate" "cloudfront" {
  provider          = aws.us-east-1  # CloudFront requires certificates in us-east-1
  domain_name       = var.domain_name
  validation_method = "DNS"
  
  subject_alternative_names = ["*.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment} distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  aliases             = [var.domain_name, "*.${var.domain_name}"]

  # ALB Origin
  origin {
    domain_name = var.primary_alb_dns_name
    origin_id   = "${local.alb_origin_id}-primary"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = var.secondary_alb_dns_name
    origin_id   = "${local.alb_origin_id}-secondary"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.alb_origin_id}-primary"

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Authorization"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Origin Groups for Failover
  origin_group {
    origin_id = "failover-group"

    failover_criteria {
      status_codes = [500, 502, 503, 504]
    }

    member {
      origin_id = "${local.alb_origin_id}-primary"
    }

    member {
      origin_id = "${local.alb_origin_id}-secondary"
    }
  }

  # WAF Integration
  web_acl_id = aws_wafv2_web_acl.cloudfront.arn

  # SSL Certificate
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  # Geo Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
}

# Route 53 Health Checks
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_alb_dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-health-check"
    }
  )
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = var.secondary_alb_dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-secondary-health-check"
    }
  )
}

# Route 53 Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name
  
  tags = var.tags
}

# Route 53 Records
resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary.id
  set_identifier  = "primary"
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "SECONDARY"
  }

  health_check_id = aws_route53_health_check.secondary.id
  set_identifier  = "secondary"
}