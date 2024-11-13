provider "aws" {
  region = "ap-southeast-1"
}

output "dns" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3" {
  value = {
    regional_domain_name = aws_s3_bucket.s3_distri.bucket_regional_domain_name
    domain_name = aws_s3_bucket.s3_distri.bucket_domain_name
  }
}

