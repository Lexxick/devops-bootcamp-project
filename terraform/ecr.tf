resource "aws_ecr_repository" "project_ecr" {
  name = "devops-bootcamp/final-project-syedazam" 
  image_scanning_configuration { scan_on_push = true }
}
