variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "ami_id" {
  description = "The AMI ID for Ubuntu 24.04 LTS in the specified region"
  type        = string
  # Check AWS Public AMIs if this specific ID is deprecated
  default     = "ami-00d8fc944fb171e29" 
}
