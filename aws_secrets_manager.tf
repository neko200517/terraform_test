#----------------------------------------
# Secrets_Managerの作成
#----------------------------------------
# Secrets Manager の作成
resource "aws_secretsmanager_secret" "default" {
  name = "${var.project_name}-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id = aws_secretsmanager_secret.default.id
 
  secret_string = jsonencode({
    username : aws_db_instance.default.username
    password : aws_db_instance.default.password
    engine : aws_db_instance.default.engine
    host : aws_db_instance.default.endpoint
    port : aws_db_instance.default.port
    dbInstanceIdentifier : aws_db_instance.default.id
  })
}

# エンドポイント用セキュリティグループ
resource "aws_security_group" "endpoint_security_group" {
  name   = "${var.project_name}-endpoint-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = false
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = false
  }
  
  tags = {
    Name = "${var.project_name}-endpoint-sg"
  }
}

# エンドポイント
resource "aws_vpc_endpoint" "secretsmanager" {
  service_name       = "com.amazonaws.${var.region}.secretsmanager"
  security_group_ids = [aws_security_group.endpoint_security_group.id]
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  subnet_ids          = [
      aws_subnet.private_1a.id,
      aws_subnet.private_1c.id,
      aws_subnet.private_1d.id
      ]
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-secrets-manager-endpoint"
  }
}
