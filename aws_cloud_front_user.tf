#----------------------------------------
# CloudFrontの作成
#----------------------------------------
# オリジンアクセスアイデンティティの作成
resource "aws_cloudfront_origin_access_identity" "site_user" {
  comment = aws_s3_bucket.site_user.bucket_regional_domain_name
}

# ディストリビューションの作成
resource "aws_cloudfront_distribution" "site_user" {

  # オリジンドメイン
  origin {
    domain_name = aws_s3_bucket.site_user.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.site_user.id

    # S3オリジンのパスを指定
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.site_user.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "For User"
  default_root_object = "index.html"

  # ビヘイビア（デフォルト）
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.site_user.id

    # 圧縮
    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    # キャッシュとオリジンリクエスト
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0

    # キャッシュポリシー
    # Amplify          ID: 2e54312d-136d-493c-8eb9-b001f22f67d2
    # CachingDisabled  ID: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad
    # CachingOptimized ID: 658327ea-f89d-4fab-a63d-7e88639e58f6
    # cache_policy_id = 658327ea-f89d-4fab-a63d-7e88639e58f6

    # レスポンスヘッダポリシー
    # CORS-and-SecurityHeadersPolicy                ID: e61eb60c-9c35-4d20-a928-2b84e02af89c
    # CORS-with-preflight-and-SecurityHeadersPolicy ID: eaab4381-ed33-4a86-88ca-d9558dc6cd63
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id

  }

  # 料金クラス
  # PriceClass_All, PriceClass_200, PriceClass_100
  price_class = "PriceClass_All"

  # 配布制限
  # 日本のみ
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP", "US"]
    }
  }

  # タグ
  # tags = {}

  # エイリアス
  aliases = ["${var.domain.user_domain}"]

  # # 証明書設定
  # viewer_certificate {
  #   acm_certificate_arn      = aws_acm_certificate.acm_cert.arn
  #   ssl_support_method       = "sni-only"
  #   minimum_protocol_version = "TLSv1.2_2021"
  # }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # WAF
  web_acl_id = aws_wafv2_web_acl.web_acl_cf.arn

}

# 作成されたCloudFront Destributionのドメインを出力
output "cloud_front_destribution_domain_name_user" {
  value = "${aws_cloudfront_distribution.site_user.domain_name}"
}