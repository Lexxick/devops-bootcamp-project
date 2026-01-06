resource "aws_security_group" "devops-public-sg" {
  name        = "devops-public-sg"
  description = "Web server SG: HTTP + SSH + node exporter"
  vpc_id      = aws_vpc.devops-vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.devops-vpc.cidr_block]
  }

  ingress {
    description = "Node exporter from monitoring server only"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.136/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "devops-public-sg"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_security_group" "devops-private-sg" {
  name        = "devops-private-sg"
  description = "Private SG: SSH from VPC only"
  vpc_id      = aws_vpc.devops-vpc.id

  ingress {
    description = "SSH from VPC only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.devops-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "devops-private-sg"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

