resource "aws_s3_bucket" "s3_distri" {
  bucket = "terraform-distribution-test-9898"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "s3_distri" {
  bucket = aws_s3_bucket.s3_distri.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_distri" {
  depends_on = [ aws_s3_bucket_ownership_controls.s3_distri ]
  bucket = aws_s3_bucket.s3_distri.id
  acl = "private"
}

resource "aws_s3_bucket_website_configuration" "s3_distri" {
  bucket = aws_s3_bucket.s3_distri.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "s3_distri" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_distri.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_distri" {
  bucket = aws_s3_bucket.s3_distri.id
  policy = data.aws_iam_policy_document.s3_distri.json
}