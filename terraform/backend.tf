terraform {
  backend "s3" {
    bucket  = "devops-bootcamp-terraform-syedazam"
    key     = "terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
