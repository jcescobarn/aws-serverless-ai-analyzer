resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.s3_frontend_bucket_name
}

resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- 5. FRONTEND: CloudFront (CDN) ---

# Usamos Origin Access Identity (OAI) para compatibilidad con permisos limitados
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${aws_s3_bucket.frontend_bucket.bucket}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend_bucket.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend_bucket.bucket}"

    viewer_protocol_policy = "redirect-to-https"

    # Política de caché estándar
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # Configuración de certificado por defecto de CloudFront (para HTTPS)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Política del bucket S3 para permitir que CloudFront lea los archivos usando OAI
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
      },
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
    }]
  })
}