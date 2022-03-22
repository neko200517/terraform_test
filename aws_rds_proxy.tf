#----------------------------------------
# RDS Proxy の作成
#----------------------------------------
## dbproxy
resource "aws_iam_role" "dbproxy" {
  name = "${var.project_name}-db-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.dbproxy_assume.json
}

data "aws_iam_policy_document" "dbproxy_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "dbproxy" {
  name   = "${var.project_name}-db-proxy-policy"
  role   = aws_iam_role.dbproxy.id
  policy = data.aws_iam_policy_document.dbproxy_custom.json
}

# dbproxy_custom
data "aws_iam_policy_document" "dbproxy_custom" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "arn:aws:secretsmanager:*:*:*",
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      "*",
    ]
  }
}

# RDS Proxy
resource "aws_db_proxy" "default" {
  name                   = "${var.project_name}-rds-proxy"
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 60
  require_tls            = false
  role_arn               = aws_iam_role.dbproxy.arn
  vpc_security_group_ids = [aws_security_group.rds.id]
  vpc_subnet_ids         = [
      "${aws_subnet.private_1a.id}",
      "${aws_subnet.private_1c.id}",
      "${aws_subnet.private_1d.id}"
      ]

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.default.arn
  }
}

resource "aws_db_proxy_default_target_group" "default" {
  db_proxy_name = aws_db_proxy.default.name

  connection_pool_config {
    connection_borrow_timeout = 120
    max_connections_percent = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "avex_charege_db_proxy_target" {
  db_proxy_name = aws_db_proxy.default.name
  db_instance_identifier = aws_db_instance.default.id
  target_group_name = aws_db_proxy_default_target_group.default.name
}

# resource "aws_ssm_parameter" "db_host" {
#   name = "${var.project_name}-db-host"
#   type = "SecureString"
#   value = aws_db_proxy.default.endpoint
# }

# resource "aws_ssm_parameter" "db_name" {
#   name = "${var.project_name}-db-name"
#   type = "SecureString"
#   value = aws_db_instance.default.engine
# }

# resource "aws_ssm_parameter" "db_usename" {
#   name = "${var.project_name}-db-username"
#   type = "SecureString"
#   value = aws_db_instance.default.username
# }

# resource "aws_ssm_parameter" "db_password" {
#   name = "${var.project_name}-db-username"
#   type = "SecureString"
#   value = aws_db_instance.default.password
# }

# resource "aws_ssm_parameter" "db_port" {
#   name = "${var.project_name}-db-port"
#   type = "SecureString"
#   value = aws_db_instance.default.port
# }
