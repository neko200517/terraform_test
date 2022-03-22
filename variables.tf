# 環境変数
# 例）terraform apply -var-file=<ステージ>.tfvars
variable "project_name" {}
variable "region" {}
variable "environment" {}
variable "vpc" {}
variable "domain" {}
variable "apigateway" {}
variable "emails" {}

# 共通定義
locals {
  user = {
    target = "user"
    s3_prefix = "a4v9krn8"
  }
  staff = {
    target = "staff"
    s3_prefix = "m34abzp2"
  }

  myIp = "106.72.132.65/32"
  
  webacl = {
    rules = {
      ip = "ip-restriction-rule"
      rate = "rate-based-restriction-rule"
      size = "size-restriction-rule"
      geo = "geo-restriction-rule"
    }
    cf = {
      name = "waf-cf"
    }
    ag = {
      name = "waf-ag"
    }
  }
}
