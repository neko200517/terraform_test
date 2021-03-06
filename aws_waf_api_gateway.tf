#----------------------------------------
# WAFの作成
#----------------------------------------
resource "aws_wafv2_web_acl" "web_acl_ag" {
  name        = "${var.project_name}-${local.webacl.ag.name}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # サイズ（8192KBを超えるリクエストを遮断）
  rule {
    name     = local.webacl.rules.size
    priority = 0

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = 8192

        field_to_match {
          body {}
        }

        text_transformation {
          priority = 5
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.project_name}-${local.webacl.ag.name}-${local.webacl.rules.size}"
      sampled_requests_enabled   = false
    }
  }

  # # IP（許可IP以外を制限）
  # rule {
  #   name     = local.webacl.rules.ip
  #   priority = 1

  #   action {
  #     block {}
  #   }

  #   statement {
  #     not_statement {
  #       statement {
  #         ip_set_reference_statement {
  #           arn = aws_wafv2_ip_set.ip_set_ag.arn
  #         }
  #       }
  #     }
  #   }

  #   visibility_config {
  #     cloudwatch_metrics_enabled = false
  #     metric_name                = "${var.project_name}-${local.webacl.ag.name}-${local.webacl.rules.ip}"
  #     sampled_requests_enabled   = false
  #   }
  # }

  # 国（日本以外を制限）
  rule {
    name     = local.webacl.rules.geo
    priority = 2

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["JP"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.project_name}-${local.webacl.ag.name}-${local.webacl.rules.geo}"
      sampled_requests_enabled   = false
    }
  }

  # レートベースド（5分間にn回アクセスで制限）
  rule {
    name     = local.webacl.rules.rate
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.project_name}-${local.webacl.ag.name}-${local.webacl.rules.rate}"
      sampled_requests_enabled   = false
    }
  }

  # AWS-AWSManagedRulesAmazonIpReputationList
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  # AWS-AWSManagedRulesAnonymousIpList
  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  # AWS-AWSManagedRulesCommonRuleSet
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 6

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
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWS-AWSManagedRulesKnownBadInputsRuleSet
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 7

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWS-AWSManagedRulesSQLiRuleSet
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 8

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.project_name}-${local.webacl.ag.name}"
    sampled_requests_enabled   = false
  }

  # tags = {}
}

# IPセット
resource "aws_wafv2_ip_set" "ip_set_ag" {
  name               = "${var.project_name}-${local.webacl.ag.name}-ip-set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = []

  # tags = {}
}

# 適応
resource "aws_wafv2_web_acl_association" "web_acl_ag_user" {
  // Serverless Framewark ですでに作成済リソースを割り当て
  resource_arn = "arn:aws:apigateway:ap-northeast-1::/restapis/${var.apigateway.id}/stages/${var.environment}"
  web_acl_arn  = aws_wafv2_web_acl.web_acl_ag.arn
}

# ロググループの作成
resource "aws_cloudwatch_log_group" "web_acl_ag" {
  name = "aws-waf-logs-${var.project_name}-${local.webacl.ag.name}"
  # tags = {}
}

# ロググループと関連付け
resource "aws_wafv2_web_acl_logging_configuration" "web_acl_ag" {
  log_destination_configs = [aws_cloudwatch_log_group.web_acl_ag.arn]
  resource_arn = aws_wafv2_web_acl.web_acl_ag.arn
}
