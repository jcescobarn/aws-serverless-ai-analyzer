data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_caller_identity" "current" {}

module "backend" {
  source = "./modules/backend"

  s3_image_bucket_name = var.s3_image_bucket_name
}

module "frontend" {
  source = "./modules/frontend"

  s3_frontend_bucket_name = var.s3_frontend_bucket_name
}