# Define required providers and versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = "default"
}

# Configure S3 Backend for state management
terraform {
  backend "s3" {
    bucket       = "devops-bootcamp-project-syedazam" # <<-- !! REPLACE with your UNIQUE bucket name
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
  }
}
