resource "aws_s3_bucket" "s3_pre_pro" {
  bucket = "terraform-serries-s3-pre-pro-9"
  force_destroy = true
}


resource "aws_s3_bucket_ownership_controls" "s3_pre_pro" {
  bucket = aws_s3_bucket.s3_pre_pro.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_pre_pro" {
  bucket = aws_s3_bucket.s3_pre_pro.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "s3_pre_pro" {

  depends_on = [ aws_s3_bucket_ownership_controls.s3_pre_pro, aws_s3_bucket_public_access_block.s3_pre_pro ]

  bucket = aws_s3_bucket.s3_pre_pro.id
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "s3_pre_pro" {
  bucket = aws_s3_bucket.s3_pre_pro.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "s3_pre_pro" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_pre_pro.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      ]
    }
  }

}

resource "aws_s3_bucket_policy" "s3_pre_pro" {
  bucket = aws_s3_bucket.s3_pre_pro.id
  policy = data.aws_iam_policy_document.s3_pre_pro.json
}