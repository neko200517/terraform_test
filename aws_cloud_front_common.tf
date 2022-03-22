#----------------------------------------
# CloudFront セキュリティヘッダポリシー
#----------------------------------------
locals {
  csp = [
    "frame-ancestors 'none';",
    "connect-src 'self' *.amazonaws.com *.keytecho.com *.cloudflare.com;",
    "default-src 'self';",
    "img-src 'self' data:;",
    "script-src 'self';",
    "style-src 'self' 'unsafe-inline' *.cloudflare.com;",
    "style-src-elem 'self' *.cloudflare.com;",
    "object-src 'none';",
    "font-src data: *.cloudflare.com;"
  ]
}

resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "${var.project_name}-security-headers-policy"

  security_headers_config {
    # x-content-type-options: nosniff
    content_type_options {
      override = true
    }

    # x-frame-options: DENY | SAMEORIGIN
    frame_options {
      frame_option = "DENY"
      override     = true
    }

    # referrer-policy: strict-origin-when-cross-origin
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    # x-xss-protection: 1; mode=block
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    # strict-transport-security: max-age=63072000; includeSubdomains; preload
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    # content-security-policy
    content_security_policy {
      content_security_policy = "${local.csp[0]} ${local.csp[1]} ${local.csp[2]} ${local.csp[3]} ${local.csp[4]} ${local.csp[5]} ${local.csp[6]}  ${local.csp[7]} ${local.csp[8]}"
      override                = true
    }
  }
}
