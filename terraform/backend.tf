terraform {
  backend "s3" {
    bucket  = "devops-bootcamp-terraform-syedazam" # must be unique
    key     = "terraform/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
