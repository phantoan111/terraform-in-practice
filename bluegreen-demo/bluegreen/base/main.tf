resource "random_string" "rand" {
  length = 24
  special = false
  upper = false
}

locals {
  namespace =  var.namespace != "" ? substr(join("-", [var.namespace, random_string.rand.result ]), 0, 24) : random_string.rand.result
}

resource "aws_resourcegroups_group" "resourcegroups_group" {
  name = "${local.namespace}-group"

  resource_query {
    query = <<-JSON
      {
        "ResourceTypeFilters": [
          "AWS::AllSupported"
        ],
        "TagFilters": [
          {
            "Key": "ResourceGroup",
            "Values": ["${local.namespace}"]
          }
        ]
      }
    JSON
  }
}

data "aws_availability_zones" "available" {
  
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # version = ""
  name = "${local.namespace}-vpc"
  cidr = "10.0.0.0/16"
  azs = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24","10.0.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "lb_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"
  name = "lb_sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "web_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name = "web_sg"
  vpc_id = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      rule = "ssh-tcp"
      cidr_blocks = "10.0.0.0/16"
    }
  ]
  ingress_with_source_security_group_id = [{
    rule = "http-8080-tcp"
    source_security_group_id = "${module.lb_sg.security_group_id}"
  }]
}

resource "aws_lb" "lb" {
  name = "${local.namespace}-lb"
  subnets = module.vpc.public_subnets
  security_groups = [module.lb_sg.security_group_id]
  tags = {
    ResourceGroup = local.namespace
  }
}

resource "aws_lb_target_group" "blue_target_group" {
  name = "${local.namespace}-blue"
  port = 8080
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc.vpc_id
  tags = {
    ResourceGroup =local.namespace
  }
}

resource "aws_lb_target_group" "green_target_group" {
  name = "${local.namespace}-green"
  port = 8080
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc.vpc_id
  tags = {
    ResourceGroup = local.namespace
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = var.production == "green" ? aws_lb_target_group.green_target_group.arn : aws_lb_target_group.blue_target_group.arn
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule" {
  listener_arn = aws_lb_listener.lb_listener.arn
  action {
    type = "forward"
    target_group_arn = var.production == "green" ? aws_lb_target_group.green_target_group.arn : aws_lb_target_group.blue_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/stg/*"]
    }
  }
}

module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name = "logs-role-for-module-greenblue"

  description = "Policy for logs"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action":[
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "assume_role_for_app" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role_demo" {
  name = "ec2_role_gb_module-base"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_app.json
  # managed_policy_arns = [module.iam_role.arn]
}

resource "aws_iam_role_policy_attachments_exclusive" "ec2_role_demo" {
  role_name = aws_iam_role.ec2_role_demo.name
  policy_arns = [module.iam_role.arn]
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "gb_module_instance_profile-base"
  role = aws_iam_role.ec2_role_demo.name
}