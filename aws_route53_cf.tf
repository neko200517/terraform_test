# # 利用者アプリ追加
# resource "aws_route53_record" "site_user" {
#   zone_id = var.domain.zone_id
#   name = var.domain.user_domain
#   type = "A"

#   alias {
#     name = "${aws_cloudfront_distribution.site_user.domain_name}"
#     zone_id = "${aws_cloudfront_distribution.site_user.hosted_zone_id}"
#     evaluate_target_health = false
#   }
# }

# # 指導者アプリ追加
# resource "aws_route53_record" "site_staff" {
#   zone_id = var.domain.zone_id
#   name = var.domain.staff_domain
#   type = "A"

#   alias {
#     name = "${aws_cloudfront_distribution.site_staff.domain_name}"
#     zone_id = "${aws_cloudfront_distribution.site_staff.hosted_zone_id}"
#     evaluate_target_health = false
#   }
# }

# # ACM証明書
# resource "aws_acm_certificate" "acm_cert" {
#   provider = aws.virginia
#   domain_name = "${var.domain.root_domain}"
#   subject_alternative_names = ["*.${var.domain.root_domain}"]
#   validation_method = "DNS"
# }

# # Route53にドメインを追加
# resource "aws_route53_record" "acm_cert" {
#   for_each = {
#     for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
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
# resource "aws_acm_certificate_validation" "acm_cert" {
#   provider = aws.virginia
#   certificate_arn = "${aws_acm_certificate.acm_cert.arn}"
#   validation_record_fqdns = [for record in aws_route53_record.acm_cert : record.fqdn]
# }