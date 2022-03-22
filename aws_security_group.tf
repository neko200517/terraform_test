#----------------------------------------
# セキュリティグループの作成（for SSH）
#----------------------------------------
resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-ssh-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description      = "SSH from My IP"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [local.myIp]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name             = "${var.project_name}-ssh-sg"
  }
}

#----------------------------------------
# セキュリティグループの作成（for lambda）
#----------------------------------------
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda-sg"
  description = "Only Lambda inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "only VPC"
    from_port = 0
    to_port = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-lambda-sg"
  }
}

#----------------------------------------
# セキュリティグループの作成（for RDS Proxy）
#----------------------------------------
resource "aws_security_group" "rds_proxy" {
  name        = "${var.project_name}-rds-proxy-sg"
  description = "Only RDS Proxy inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "only Lambda"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = ["${aws_security_group.lambda.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-proxy-sg"
  }
}

#----------------------------------------
# セキュリティグループの作成（for RDS）
#----------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Only VPC inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description      = "only EC2 OR RDS"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [
        "${aws_security_group.rds_proxy.id}",
        "${aws_security_group.ssh.id}"
        ]
    cidr_blocks      = ["${aws_vpc.main.cidr_block}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name             = "${var.project_name}-rds-sg"
  }
}
