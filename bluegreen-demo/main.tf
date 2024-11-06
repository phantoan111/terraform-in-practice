provider "aws" {
  region = "ap-southeast-1"
}

variable "production" {
  default = "blue"
}

module "base" {
  source = "./bluegreen/base"
  production = var.production
}

module "green" {
  source = "./bluegreen/autoscaling"
  app_version = "v1.0"
  label = "green"
  base = module.base
}

module "blue" {
  source = "./bluegreen/autoscaling"
  app_version = "v2.0"
  label = "blue"
  base = module.base
}

output "lb_dns_name" {
  value = module.base.lb_dns_name
}