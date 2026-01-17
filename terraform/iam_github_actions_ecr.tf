# terraform/iam_github_actions_ecr.tf

locals {
  github_org  = "Lexxick"
  github_repo = "devops-bootcamp-project"
  aws_region  = "ap-southeast-1"
}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    data.tls_certificate.github_actions.certificates[0].sha1_fingerprint
  ]
}

resource "aws_iam_role" "github_actions_ecr_push" {
  name = "github-actions-ecr-push"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          # only allow this repo
          "token.actions.githubusercontent.com:sub" = "repo:${local.github_org}/${local.github_repo}:*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "github_actions_ecr_push" {
  name = "github-actions-ecr-push-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Needed to login to ECR
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },

      # Needed to push/pull layers + put image
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = aws_ecr_repository.app.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  role       = aws_iam_role.github_actions_ecr_push.name
  policy_arn = aws_iam_policy.github_actions_ecr_push.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_ecr_push.arn
}
