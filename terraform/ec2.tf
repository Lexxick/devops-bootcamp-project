resource "aws_instance" "web-server" {
  ami                    = "ami-00d8fc944fb171e29"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.devops-public-subnet.id
  security_groups        = [aws_security_group.devops-public-sg.id]
  private_ip             = "10.0.0.5"
  key_name               = aws_key_pair.ansible.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "web-server" 
  Role = "web"
  }
}

resource "aws_instance" "ansible-controller" {
  ami                         = "ami-00d8fc944fb171e29"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.devops-private-subnet.id
  security_groups             = [aws_security_group.devops-private-sg.id]
  private_ip                  = "10.0.0.135"
  key_name                    = aws_key_pair.ansible.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  
 # User data script to install prerequisites
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install pipx
    pipx install --include-deps ansible
    pipx ensurepath
    sudo apt install git -y
    git clone https://github.com/Lexxick/devops-bootcamp-project.git

  EOF

  tags = { Name = "ansible-controller" 
  Role = "ansible"
  }
}

resource "aws_instance" "monitoring-server" {
  ami                         = "ami-00d8fc944fb171e29"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.devops-private-subnet.id
  security_groups             = [aws_security_group.devops-private-sg.id]
  private_ip                  = "10.0.0.136"
  key_name                    = aws_key_pair.ansible.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "monitoring-server" 
  Role = "monitoring"
  }
}