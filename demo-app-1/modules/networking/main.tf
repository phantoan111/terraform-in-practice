data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "${var.project}-vpc"
  cidr = var.vpc_cidr
  azs = data.aws_availability_zones.available.names
  
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames = true

  

}

module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name = "alb-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["http-80-tcp"]
}

module "web_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name = "web-sg"
  vpc_id = module.vpc.vpc_id
  # ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_with_source_security_group_id = [{
    rule = "http-80-tcp"
    source_security_group_id = "${module.alb_sg.security_group_id}"
  }]
}

module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name = "db-sg"
  vpc_id = module.vpc.vpc_id
  # ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_with_source_security_group_id = [
  {
    rule = "postgresql-tcp"
    source_security_group_id = "${module.web_sg.security_group_id}"
  }
  ]
}