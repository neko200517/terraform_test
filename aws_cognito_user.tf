#----------------------------------------
# Cognitoの作成（for User）
#----------------------------------------
// ユーザプール
resource "aws_cognito_user_pool" "user" {
  name = "${var.project_name}-for-user-user-pool"
  
  # パスワードの強度
  password_policy {
    minimum_length                   = 6
    require_lowercase                = false # 英小文字
    require_numbers                  = false # 数字
    require_symbols                  = false # 記号
    require_uppercase                = false # 英大文字
    temporary_password_validity_days = 7 # 初期登録時の一時的なパスワードの有効期限
  }

  # ユーザーに自己サインアップを許可する
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

// ユーザプールクライアント
resource "aws_cognito_user_pool_client" "user" {
  name = "${var.project_name}-for-user-user-pool-client"

  # 更新トークンの期限
  refresh_token_validity       = 1
  user_pool_id                 = aws_cognito_user_pool.user.id
}

// identity_pool
resource "aws_cognito_identity_pool" "user" {
  identity_pool_name               = "${var.project_name}-for-user-identity-pool"

  # 認証していないユーザーを許可する
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.user.id
    provider_name           = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.user.id}"
  }
}

// ロール
resource "aws_iam_role" "authenticated_user" {
  name = "${var.project_name}-for-user-cognito-user-auth-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.user.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

// ポリシー
resource "aws_iam_role_policy" "authenticated_user" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated_user.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

// ロールの割り当て
resource "aws_cognito_identity_pool_roles_attachment" "user" {
  identity_pool_id = aws_cognito_identity_pool.user.id

  roles = {
    "authenticated" = aws_iam_role.authenticated_user.arn
  }
}