terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "./vpc"
  vpc_cidr_block = "10.0.0.0/16"
  private_subnet = ["10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24"]
  public_subnet = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  avaiable_zone = ["ap-southeast-1a","ap-southeast-1b","ap-southeast-1c"]
}