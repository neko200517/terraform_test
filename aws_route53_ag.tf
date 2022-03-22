# # ACM証明書
# resource "aws_acm_certificate" "acm_cert_ag" {
#   domain_name = "${var.domain.root_domain}"
#   subject_alternative_names = ["*.${var.domain.root_domain}"]
#   validation_method = "DNS"
# }

# # Route53にドメインを追加
# resource "aws_route53_record" "acm_cert_ag" {
#   for_each = {
#     for dvo in aws_acm_certificate.acm_cert_ag.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#   allow_overwrite =  true
#   name = each.value.name
#   records = [each.value.record]
#   ttl = 60
#   type = each.value.type
#   zone_id = var.domain.zone_id
# }

# # ACMをDNS認証
# resource "aws_acm_certificate_validation" "acm_cert_ag" {
#   certificate_arn = "${aws_acm_certificate.acm_cert_ag.arn}"
#   validation_record_fqdns = [for record in aws_route53_record.acm_cert_ag : record.fqdn]
# }

# #----------------------------------------
# # API Gatewayカスタムドメイン作成
# #----------------------------------------
# resource "aws_api_gateway_domain_name" "my_domain" {
#   domain_name              = "${var.domain.api_domain}"
#   regional_certificate_arn = aws_acm_certificate_validation.acm_cert_ag.certificate_arn
#   security_policy          = "TLS_1_2"

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_base_path_mapping" "my_domain" {
#   api_id      = var.apigateway.id
#   stage_name  = var.environment
#   domain_name = aws_api_gateway_domain_name.my_domain.domain_name
# }

# #----------------------------------------
# # Route53にエイリアスを設定
# #----------------------------------------
# resource "aws_route53_record" "api_gateway_alias" {
#   name    = aws_api_gateway_domain_name.my_domain.domain_name
#   type    = "A"
#   zone_id = var.domain.zone_id

#   alias {
#     evaluate_target_health = true
#     name                   = aws_api_gateway_domain_name.my_domain.regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.my_domain.regional_zone_id
#   }
# }
