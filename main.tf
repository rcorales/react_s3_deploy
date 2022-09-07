provider "aws" {
  region = var.aws_region
}
provider "aws" {
  region = "us-east-1"
  alias = "use1"
}
locals {
  domain = "${var.domain_name}"
  s3_origin_id = "s3-react-aws-terraform-github-actions"
}

resource "aws_s3_bucket" "example" {
  bucket = "${var.prefix}-${var.bucket_name}"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket
  

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

resource "aws_s3_bucket_policy" "ACCESS_BUCKETPOLICY" {
  bucket = aws_s3_bucket.example.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::${var.prefix}-${var.bucket_name}/*"
        }
    ]
}
POLICY
}


# resource "aws_acm_certificate" "react-aws-terraform-github-actions-cert" {
#   provider = aws.use1
#   domain_name = local.domain
#   validation_method = "DNS"
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_cloudfront_distribution" "react-aws-terraform-github-actions" {
#   enabled = true
#   is_ipv6_enabled = true
#   comment = "The cloudfront distribution for react-aws-terraform-github-actions.ryanc.com"
#   default_root_object = "index.html"
#   aliases = [local.domain]
#   default_cache_behavior {
#     allowed_methods = ["GET", "HEAD"]
#     cached_methods = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id
#     viewer_protocol_policy = "redirect-to-https"
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "all"
#       }
#     }
#   }
#   origin {
#     domain_name = aws_s3_bucket.example.bucket_regional_domain_name
#     origin_id = local.s3_origin_id
#   }
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
#   viewer_certificate {
#     acm_certificate_arn = aws_acm_certificate.react-aws-terraform-github-actions-cert.arn
#     ssl_support_method = "sni-only"
#   }
#   custom_error_response {
#     error_code = 404
#     error_caching_min_ttl = 86400
#     response_page_path = "/index.html"
#     response_code = 200
#   }
# }

# resource "aws_iam_policy" "cloudfront-invalidate-paths" {
#   name = "cloudfront-invalidate-paths"
#   description = "Used by CI pipelines to delete cached paths"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid = "VisualEditor0",
#         Effect = "Allow",
#         Action = "cloudfront:CreateInvalidation",
#         Resource = "*"
#       }
#     ]
#   })
# }

