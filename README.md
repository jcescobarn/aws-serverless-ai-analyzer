# AWS Serverless AI Analyzer

A serverless web application that analyzes images using AWS Rekognition. Upload an image and get AI-powered labels and insights about the content.

## Architecture

This project implements a serverless architecture using:

- **Frontend**: Static website hosted on Amazon S3
- **Backend**: AWS Lambda functions for image processing
- **API**: Amazon API Gateway for REST endpoints
- **AI**: Amazon Rekognition for image analysis
- **Storage**: Amazon S3 for image storage
- **Infrastructure**: Terraform for Infrastructure as Code
- **CI/CD**: GitHub Actions for automated deployment

## Project Structure

```
aws-serverless-ai-analyzer/
├── frontend/                    # Static web application
│   ├── index.html              # Main HTML page
│   ├── script.js               # Frontend JavaScript logic
│   └── style.css               # Styling
├── src_upload/                 # Upload Lambda function
│   └── upload_url.py           # Generates S3 presigned URLs
├── src_analyze/                # Analysis Lambda function
│   └── analyze.py              # Rekognition image analysis
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── backend.tf              # Remote state configuration
│   ├── providers.tf            # Provider configuration
│   └── modules/                # Terraform modules
│       ├── backend/            # Backend infrastructure
│       ├── frontend/           # Frontend infrastructure
│       └── networking/         # Network configuration
├── .github/workflows/          # CI/CD pipelines
│   ├── infra.yml              # Infrastructure deployment
│   └── frontend               # Frontend deployment
└── docker-compose.yaml        # Local development environment
```

## Features

- **Image Upload**: Secure file upload using S3 presigned URLs
- **AI Analysis**: Automatic image labeling with AWS Rekognition
- **Responsive UI**: Clean, mobile-friendly interface
- **CORS Enabled**: Cross-origin requests support
- **Infrastructure as Code**: Fully automated infrastructure deployment

## Technology Stack

### Frontend
- HTML5, CSS3, JavaScript (Vanilla)
- S3 Static Website Hosting

### Backend
- Python 3.10
- AWS Lambda
- Amazon API Gateway
- Amazon S3
- Amazon Rekognition

### Infrastructure
- Terraform
- AWS Cloud
- GitHub Actions

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- GitHub repository with Actions enabled
- AWS CLI configured (for local development)

## AWS Academy Limitations

**Note**: This project was developed using AWS Academy, which has certain service limitations:
- **CloudFront**: Not available in AWS Academy, so the project uses S3 static website hosting directly
- **Some IAM permissions**: Limited permissions may require simplified configurations
- **Service availability**: Some AWS services may not be accessible in the learning environment

The architecture has been adapted to work within these constraints while maintaining the core serverless functionality.

## Setup & Deployment

### 1. Configure AWS Credentials

Set up GitHub Secrets for AWS access:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (if using temporary credentials)

### 2. Infrastructure Deployment

The infrastructure deploys automatically via GitHub Actions when changes are pushed to the `terraform/` directory.

Manual deployment:
```bash
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 3. Frontend Deployment

The frontend deploys automatically when changes are pushed to the `frontend/` directory.

Manual deployment:
```bash
aws s3 sync ./frontend/ s3://your-frontend-bucket --delete
```

### 4. Configuration

Update the API Gateway URL in the frontend deployment workflow or directly in `frontend/script.js`:
```javascript
const API_ENDPOINT = "https://your-api-gateway-id.execute-api.region.amazonaws.com/prod";
```

## Usage

1. **Access the Application**: Visit your S3 static website URL
2. **Upload Image**: Click "Choose File" and select a JPG/PNG image
3. **Analyze**: Click "Analyze Image" to process the image
4. **View Results**: See AI-generated labels and confidence scores

## API Endpoints

### POST /upload-url
Generates a presigned URL for image upload to S3.

**Response:**
```json
{
  "uploadURL": "https://s3.amazonaws.com/...",
  "key": "unique-file-key.jpg"
}
```

### POST /analyze
Analyzes an uploaded image using AWS Rekognition.

**Request:**
```json
{
  "bucket": "image-bucket-name",
  "key": "image-file-key.jpg"
}
```

**Response:**
```json
{
  "labels": ["Person", "Car", "Building", "Outdoor"]
}
```

## Local Development

### Using Docker Compose

```bash
docker compose up -d
```

This provides a containerized development environment with all necessary tools.

### Environment Variables

Required environment variables for Lambda functions:
- `IMAGE_BUCKET_NAME`: S3 bucket name for image storage

## Configuration Files

### terraform.tfvars
```hcl
s3_image_bucket_name = "your-image-bucket"
s3_frontend_bucket_name = "your-frontend-bucket"
aws_region = "us-east-1"
```

## Security Features

- **Presigned URLs**: Secure, time-limited upload URLs
- **CORS Configuration**: Proper cross-origin request handling
- **IAM Roles**: Least-privilege access for Lambda functions
- **No Public Policies**: Secure S3 bucket configuration

## CI/CD Pipeline

### Infrastructure Pipeline
- Triggered on changes to `terraform/**`
- Validates and applies Terraform configurations
- Creates ZIP packages for Lambda functions

### Frontend Pipeline
- Triggered on changes to `frontend/**`
- Injects configuration variables
- Deploys static files to S3

## Cost Optimization

- Serverless architecture (pay-per-use)
- S3 lifecycle policies for old images
- Lambda memory and timeout optimization

**Built using AWS Serverless Technologies**