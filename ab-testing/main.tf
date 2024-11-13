provider "aws" {
  region = "us-east-1"
}

output "dns" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3" {
  value = {
    pro  = aws_s3_bucket.s3_pro.bucket_regional_domain_name
    pre_pro = aws_s3_bucket.s3_pre_pro.bucket_regional_domain_name
  }
}
# output "arn" {
#   value = aws_lambda_function.origin_response_function.qualified_arn
# }