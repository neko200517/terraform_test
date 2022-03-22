################################################################################
# IAM Role for API Gateway Put CloudWatch Logs                                 #
################################################################################
resource "aws_iam_role" "apigateway_putlog" {
  name = "${var.project_name}-APIGatewayPushLogsRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apigateway_putlog" {
  role       = "${aws_iam_role.apigateway_putlog.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

################################################################################
# Lambda + RDS Proxy + Secrets Manager
################################################################################
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# ポリシー：Secrets Manager
data "aws_iam_policy_document" "lambda_secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:*:*:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_1" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_2" {
  name   = "${var.project_name}-lambda-secrets-manager"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_secrets_manager.json
}
