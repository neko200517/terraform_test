#----------------------------------------
# RDSの作成
#----------------------------------------

# サブネットグループの作成
resource "aws_db_subnet_group" "default" {
    name = "${var.project_name}-db-sg"
    subnet_ids = [
        "${aws_subnet.private_1a.id}",
        "${aws_subnet.private_1c.id}",
        "${aws_subnet.private_1d.id}"
    ]
    tags = {
        Name = "${var.project_name}-db-sg"
    }
}

# RDSインスタンスの作成
resource "aws_db_instance" "default" {
  identifier = "${var.project_name}-db"
  allocated_storage = 20
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "12.9"
  instance_class = "db.t2.micro"
  name = "postgres"
  username = "postgres"
  password = "postgres"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  availability_zone = "${var.region}a"
  skip_final_snapshot = true
}