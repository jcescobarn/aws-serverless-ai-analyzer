variable "aws_region" {
  description = "AWS Region to deploy"
  type        = string
  default     = "us-east-1"
}

variable "s3_image_bucket_name" {
  description = "Name to the images bucket"
  type        = string
}

variable "s3_frontend_bucket_name" {
  description = "Name to frontend bucket"
  type        = string
}
