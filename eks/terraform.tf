terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.70.0"
        }
    }
}

provider "aws" {
    region = "ap-southeast-1"
}