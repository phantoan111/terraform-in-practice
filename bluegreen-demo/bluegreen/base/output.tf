output "vpc" {
  value = module.vpc
}

output "namespace" {
  value = local.namespace
}

output "sg" {
  value = {
    lb = module.lb_sg.security_group_id
    webserver = module.web_sg.security_group_id
  }
}

output "target_group_arns" {
  value = {
    blue = [aws_lb_target_group.blue_target_group.arn]
    green = [aws_lb_target_group.green_target_group.arn]
  }
}

output "lb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "iam_instance_role" {
  value = aws_iam_instance_profile.iam_instance_profile.name
}