#-----------database/main.tf------------

resource "aws_db_instance" "tf_db_instance" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "tf_db"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${var.db_subnet_group_name}"
  skip_final_snapshot = true
}