output "vpc" {
  value = module.vpc
}

output "sg" {
  value = {
    lb = module.alb_sg.security_group_id
    web = module.web_sg.security_group_id
    db =  module.db_sg.security_group_id
  }
}