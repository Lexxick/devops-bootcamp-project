#terraform init -migrate-state --auto-approve = to use S3 bucket for terraform.tfstate
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket       = "devops-bootcamp-project-syedazam"
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}