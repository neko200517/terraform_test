#----------------------------------------
# AMI
#----------------------------------------
# 最新版のAmazonLinux2のAMI情報
data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

#----------------------------------------
# EC2 Key Pairs
#----------------------------------------
resource "aws_key_pair" "common-ssh" {
  key_name   = "${var.project_name}-key-pair"
  public_key = file("./.ssh/keypair.pub")
  tags = {}
}

# #----------------------------------------
# # IAM Role (S3FullAccess)
# #----------------------------------------
# resource "aws_iam_instance_profile" "instance_role" {
#     name = "${var.project_name}-instance-role"
#     role = "${aws_iam_role.instance_role.name}"
# }

# resource "aws_iam_role" "instance_role" {
#     name = "${var.project_name}-instance-role"
#     assume_role_policy = file("./policy/ec2_assume_role_policy.json")
# }

# resource "aws_iam_role_policy" "instance_role_policy" {
#     name = "${var.project_name}-instance-role-policy"
#     role = "${aws_iam_role.instance_role.id}"
#     policy = file("./policy/s3_full_access_policy.json")
# }

#----------------------------------------
# EC2インスタンスの作成
#----------------------------------------
resource "aws_instance" "web" {
  ami = data.aws_ami.example.image_id
  instance_type = "t2.micro"
  key_name = "${var.project_name}-key-pair"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id = aws_subnet.public_1a.id
  associate_public_ip_address = true
  availability_zone = "${var.region}a"
  monitoring = false

  # iam_instance_profile = aws_iam_instance_profile.instance_role.id

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
