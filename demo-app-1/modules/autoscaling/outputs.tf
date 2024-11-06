output "lb_dns" {
  value = aws_lb.alb_demo_app.dns_name
}