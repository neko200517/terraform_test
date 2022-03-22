# 概要

AWS サーバレス環境の構築。
以下のサービスが自動的に構築される。
Lambda と API Gateway は Serverless Framework で構築している。

### ネットワーク

- VPC
- サブネット
- インターネットゲートウェイ
- セキュリティグループ

### IAM

- IAM ロール
- IAM ポリシー

### 認証

- Cognito

### フロントエンド

- Cloud Front
- S3

### SNS

- SNS

### WAF

- WAF

### サーバ

- EC2
- RDS

### ドメイン

- Route53
- ACM

# インストール

1. Windows 環境でインストール

```bash
scoop install terraform
terraform --version
```

2. AWS CLI のインストール

3. AWS CLI の初期化、.aws/credentials の設定

# 使い方

dev.tfvars, prod.tfvars は各々の環境で変更する。

1. terraform plan の実行

```bash
terraform plan -var-file dev.tfvars
```

2. terraform apply の実行

```bash
terraform apply -var-file dev.tfvars
```

3. 削除

```bash
terraform destory
```
