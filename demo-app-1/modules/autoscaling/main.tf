data "aws_ami" "ami" {
  most_recent = true
  
  filter {
    name    = "name"
    values  = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  owners = ["amazon"]
  
}

# module "iam_instance_policy" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   name = "iam-policy-for-logs-and-rds"

#   description = "iam roles for logs and rds"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:*",
#         "rds:*"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_instance_profile" "demo_app" {
#   name = "instance_profile_for_demo_app"
#   role = aws_iam_role.instance_role.name
# }

# resource "aws_iam_role" "instance_role" {
#   name = "instance_role_for_demo_app"
#   assume_role_policy = module.iam_instance_policy.policy
# }


### Create Iam instance profile

# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.role_demo_app.name
# }

# data "aws_iam_policy_document" "assume_role_for_app" {
#  statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]

  
#   }

#   statement {
#     actions = [
#       "logs:*",
#       "rds:*"
#     ]
#     effect = "Allow"
#     resources = [
#       "*"
#     ]

#   }

# }

# resource "aws_iam_role" "role_demo_app" {
#   name               = "test_role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_for_app.json

# }


module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name = "demo-app-iam-policy_for_logs_and_rds"
  # path = "/"
  description = "Policy for logs and rds"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action":[
        "logs:*",
        "rds:*"
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
  name = "ec2_role_demo"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_app.json
  managed_policy_arns = [ module.iam_role.arn ]
}


resource "aws_iam_instance_profile" "demo_app_profile" {
  name = "demo_app_profile"
  role = aws_iam_role.ec2_role_demo.name
}


####

resource "aws_launch_template" "web" {
  name_prefix               = "web-"
  image_id                  = data.aws_ami.ami.id
  vpc_security_group_ids    = [var.sg.web]
  instance_type = "t2.micro"

  user_data = filebase64("${path.module}/run.sh")

  iam_instance_profile {
    name = aws_iam_instance_profile.demo_app_profile.name
  }

}

resource "aws_lb_target_group" "target_groups" {
  name = "demo"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc.vpc_id


}

# module "alb" {
#   source = "terraform-aws-modules/alb/aws"
#   name = var.project
#   load_balancer_type = "application"
#   vpc_id = var.vpc.vpc_id
#   subnets = var.vpc.public_subnets
#   security_groups = [var.sg.lb]

#   listeners = {
#     ex-http = {
#       port    = 80
#       protocol = "HTTP"

#       forward = {
#         target_group_key = "ex-instance"
#       }
#     }
#   }

#   target_groups = {
#     ex-instance = {
#       name_prefix = "web"
#       protocol  = "HTTP"
#       port  = 80
#       target_type = "instance"
#       # target_id = aws_lb_target_group.target_groups.id
#     }
#   }
  
# }



### Loadbalancer
resource "aws_lb" "alb_demo_app" {
  name = "alb-demo-app"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.sg.lb]
  subnets = var.vpc.public_subnets
}

resource "aws_lb_listener" "alb_demo_app" {
  load_balancer_arn = aws_lb.alb_demo_app.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_groups.arn
  }
}



resource "aws_autoscaling_group" "web" {
  name                  = "${var.project}-asg"
  min_size              = 1
  desired_capacity = 1
  max_size              = 3
  vpc_zone_identifier   = var.vpc.private_subnets
  force_delete          = true
  target_group_arns = [aws_lb_target_group.target_groups.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  
}


resource "aws_autoscaling_attachment" "demo_attachment" {
  
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn = aws_lb_target_group.target_groups.arn
}
