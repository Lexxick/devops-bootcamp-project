resource "aws_instance" "web-server" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.devops-public-subnet.id # Public Subnet
  security_groups        = [aws_security_group.devops-public-sg.id]
  private_ip             = "10.0.0.5"
  key_name               = aws_key_pair.ansible.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name # Enable SSM
  associate_public_ip_address = true # Required for web traffic ingress

  tags = { Name = "web-server", Role = "web" }
}

# The required Elastic IP resource definition
resource "aws_eip" "web_server_static_ip" {
  instance = aws_instance.web-server.id
  domain   = "vpc"
  tags = { Name = "web-server-static-eip" }
}

resource "aws_instance" "ansible-controller" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.devops-private-subnet.id # Private Subnet
  security_groups             = [aws_security_group.devops-private-sg.id]
  private_ip                  = "10.0.0.135"
  key_name                    = aws_key_pair.ansible.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Enable SSM

  # User data script to install prerequisites
  user_data = <<-EOF
    #!/bin/bash
    apt update && apt upgrade -y
    apt install python3-pip git -y
    pip install pipx
    pipx ensurepath
    export PATH=$PATH:/root/.local/bin # Add pipx binaries to PATH for current session
    pipx install ansible
  EOF
  tags = { Name = "ansible-controller", Role = "ansible" }
}

resource "aws_instance" "monitoring-server" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.devops-private-subnet.id # Private Subnet
  security_groups             = [aws_security_group.devops-private-sg.id]
  private_ip                  = "10.0.0.136"
  key_name                    = aws_key_pair.ansible.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Enable SSM

  tags = { Name = "monitoring-server", Role = "monitoring" }
}
