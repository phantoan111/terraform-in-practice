locals {
  s3_origin_id = "access-identity-s3-pro"
  s3_origin_staging_id = "access-identity-s3-pre-pro"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = local.s3_origin_id
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  
  // origin for s3 pro
  origin {
    domain_name = aws_s3_bucket.s3_pro.bucket_regional_domain_name
    origin_id = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  
  // origin for s3 pre pro

  origin {
    domain_name = aws_s3_bucket.s3_pre_pro.bucket_regional_domain_name
    origin_id = local.s3_origin_staging_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }


  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    
    forwarded_values {
      query_string = true
      query_string_cache_keys = ["index"]

      cookies {
        forward = "all"
      }
    }

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.viewer_request_function.qualified_arn
      include_body = false
    }

    # lambda_function_association {
    #   event_type = "viewer-request"
    #   lambda_arn = module.view_request_at_edge.lambda_function_qualified_arn
    # }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.origin_request_function.qualified_arn
      include_body = false
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.origin_response_function.qualified_arn
      include_body = false
    }

    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


resource "aws_lambda_permission" "cloudfront-view-request" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.viewer_request_function.function_name
  principal = "cloudfront.amazonaws.com"
  source_arn = aws_cloudfront_distribution.s3_distribution.arn
  provider = aws.us-east-1
}

resource "aws_lambda_permission" "cloudfront-origin-request" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.origin_request_function.function_name
  principal = "cloudfront.amazonaws.com"
  source_arn = aws_cloudfront_distribution.s3_distribution.arn
  provider = aws.us-east-1
}

resource "aws_lambda_permission" "cloudfront-origin-response" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.origin_response_function.function_name
  principal = "cloudfront.amazonaws.com"
  source_arn = aws_cloudfront_distribution.s3_distribution.arn
  provider = aws.us-east-1
}