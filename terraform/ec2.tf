resource "aws_instance" "WebServer" {
  ami                    = "ami-00d8fc944fb171e29"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.devops-public-subnet.id
  security_groups        = [aws_security_group.devops-public-sg.id]
  private_ip             = "10.0.0.5"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "WebServer" 
  Role = "Web"
  }
}

resource "aws_instance" "AnsibleController" {
  ami                    = "ami-00d8fc944fb171e29"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.devops-private-subnet.id
  security_groups        = [aws_security_group.devops-private-sg.id]
  private_ip             = "10.0.0.135"
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "AnsibleController" 
  Role = "Ansible"
  }
}

resource "aws_instance" "MonitoringServer" {
  ami                    = "ami-00d8fc944fb171e29"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.devops-private-subnet.id
  security_groups        = [aws_security_group.devops-private-sg.id]
  private_ip             = "10.0.0.136"
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "MonitoringServer" 
  Role = "Monitoring"
  }
}