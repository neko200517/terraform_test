#----------------------------------------
# VPCの作成
#----------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc.cidr_block.main
  enable_dns_support               = "true" # VPC内でDNSによる名前解決を有効化するかを指定
  enable_dns_hostnames             = "true" # VPC内インスタンスがDNSホスト名を取得するかを指定

  tags = {
      Name = "${var.project_name}-vpc"
  }
}

#----------------------------------------
# Subnetの作成
#----------------------------------------
resource "aws_subnet" "public_1a" {
  vpc_id = "${aws_vpc.main.id}"

  availability_zone = "${var.region}a"

  cidr_block        = var.vpc.cidr_block.public_1a

  tags = {
    Name = "${var.project_name}-subnet-public_1a"
  }
}
# private_1a
resource "aws_subnet" "private_1a" {
  vpc_id = "${aws_vpc.main.id}"

  availability_zone = "${var.region}a"

  cidr_block        = var.vpc.cidr_block.private_1a

  tags = {
    Name = "${var.project_name}-subnet-private_1a"
  }
}
# private_1c
resource "aws_subnet" "private_1c" {
  vpc_id = "${aws_vpc.main.id}"

  availability_zone = "${var.region}c"

  cidr_block        = var.vpc.cidr_block.private_1c

  tags = {
    Name = "${var.project_name}-subnet-private_1c"
  }
}
# private_1d
resource "aws_subnet" "private_1d" {
  vpc_id = "${aws_vpc.main.id}"

  availability_zone = "${var.region}d"

  cidr_block        = var.vpc.cidr_block.private_1d

  tags = {
    Name = "${var.project_name}-subnet-private_1d"
  }
}

#----------------------------------------
# Internet Gatewayの作成
#----------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#----------------------------------------
# Route Tableの作成
#----------------------------------------
# resource "aws_route_table" "public" {
#   vpc_id = "${aws_vpc.main.id}"

#   tags = {
#     Name = "${var.project_name}-route-table"
#   }
# }

# Route
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

# Association
resource "aws_route_table_association" "public_1a" {
  subnet_id      = "${aws_subnet.public_1a.id}"
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
}