resource "aws_security_group" "devops-public-sg" {
  name        = "devops-public-sg"
  description = "Allow HTTP&SSH"
  vpc_id      = aws_vpc.devops-vpc.id

  # Allow HTTP access from anywhere (Port 80 requirement)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from the private subnet for management
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = [aws_subnet.devops-private-subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-public-sg" }
}

resource "aws_security_group" "devops-private-sg" {
  name        = "devops-private-sg"
  description = "Allow SSH VPC"
  vpc_id      = aws_vpc.devops-vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = [aws_subnet.devops-private-subnet.cidr_block]
  }

  # Allow all egress for Prometheus/Grafana to access the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-private-sg" }
}
