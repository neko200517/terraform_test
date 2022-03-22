#----------------------------------------
# S3バケットの作成
#----------------------------------------
# バケットの作成
resource "aws_s3_bucket" "site_user" {
  bucket = "${var.project_name}-${local.user.target}-hostingbucket-${local.user.s3_prefix}"
  acl    = "private"
}

# パブリックアクセス設定
resource "aws_s3_bucket_public_access_block" "site_user" {
  bucket                  = aws_s3_bucket.site_user.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バケットポリシー
resource "aws_s3_bucket_policy" "site_user" {
  bucket = aws_s3_bucket.site_user.id
  policy = jsonencode(
    {
      Id = "PolicyForCloudFrontPrivateContent"
      Statement = [
        {
          Action = "s3:GetObject"
          Effect = "Allow"
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.site_user.iam_arn
          }
          Resource = "${aws_s3_bucket.site_user.arn}/*"
          Sid      = "1"
        },
      ]
      Version = "2008-10-17"
    }
  )
}