resource "aws_ecr_repository" "devops-bootcamp-project-syedazam" {
  name = "devops-bootcamp-project-syedazam"

  image_scanning_configuration {
    scan_on_push = true
  }
}