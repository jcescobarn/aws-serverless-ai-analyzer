resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.s3_frontend_bucket_name
}


# Configuración de sitio estático público en S3
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
