resource "aws_s3_bucket" "react-app" {
  bucket = var.app_bucket
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.react-app.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "react-app" {
  bucket = aws_s3_bucket.react-app.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.react-app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.react-app.arn,
          "${aws_s3_bucket.react-app.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name = aws_s3_bucket.react-app.bucket_domain_name
    origin_id   = aws_s3_bucket.react-app.id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.react-app.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cloudfront.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cloudfront.domain_name
}
