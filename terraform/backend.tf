
terraform {
  backend "s3" {
    bucket  = "recognize-example-iac-state"
    key     = "terraform/state/aws-serverless-ai-analyzer.tfstate"
    region  = "us-east-1" # Cambia la región si tu bucket está en otra región
    encrypt = false
  }
}
