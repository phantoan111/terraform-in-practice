resource "aws_db_subnet_group" "default" {
  name = "main"
  subnet_ids = var.vpc.database_subnets

  tags = {
    Name = "My DB subnet group"
  }
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "aws_db_instance" "database" {
  allocated_storage     = 20
  engine                = "postgres"
  engine_version        = "15.8"
  instance_class        = "db.t3.micro"
  identifier            = "${var.project}-db-instance"
  db_name               = "series"
  username              = "series"
  password              = random_password.password.result
  db_subnet_group_name  = var.vpc.database_subnet_group
  vpc_security_group_ids = [var.sg.db]
  skip_final_snapshot   = true
}