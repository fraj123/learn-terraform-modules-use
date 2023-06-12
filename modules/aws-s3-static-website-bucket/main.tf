resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  bucket_prefix = var.bucket_preffix

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = var.files.index_document_suffix
  }

  error_document {
    key = var.files.error_document_key
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_bucket" {
  depends_on = [ 
    aws_s3_bucket_public_access_block.s3_bucket,
    aws_s3_bucket_ownership_controls.s3_bucket
  ]
  bucket = aws_s3_bucket.s3_bucket.id

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.s3_bucket.arn,
          "${aws_s3_bucket.s3_bucket.arn}/*",
        ]
      },
    ]
  })
}

module "template_files" {
  source = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = var.files.www_path != null ? var.files.www_path : "${path.module}/www"
}

resource "aws_s3_object" "s3_bucket" {
  for_each = var.files.terraform_managed ? module.template_files.files : {}

  bucket = aws_s3_bucket.s3_bucket.id

  key          = each.key
  source       = each.value.source_path
  content      = each.value.content
  etag         = each.value.digests.md5
  content_type = each.value.content_type
}
