resource "aws_instance" "web-server" {
  ami                         = data.aws_ami.ubuntu_24_04.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.devops-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.devops-public-sg.id]
  private_ip                  = "10.0.0.5"
  key_name                    = aws_key_pair.ansible.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name      = "web-server"
    Role      = "web"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_eip" "web_server_static_ip" {
  domain = "vpc"
  tags   = { Name = "web-server-static-eip" }
}

resource "aws_eip_association" "web_server_eip_assoc" {
  instance_id   = aws_instance.web-server.id
  allocation_id = aws_eip.web_server_static_ip.id
}

resource "aws_instance" "ansible-controller" {
  ami                         = data.aws_ami.ubuntu_24_04.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.devops-private-subnet.id
  vpc_security_group_ids      = [aws_security_group.devops-private-sg.id]
  private_ip                  = "10.0.0.135"
  key_name                    = aws_key_pair.ansible.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  user_data_replace_on_change = true
  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    inventory_content = local_file.ansible_inventory.content
    key_content       = tls_private_key.ssh_key.private_key_pem
  }))

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  depends_on = [
    aws_nat_gateway.devops_ngw,
    aws_route_table_association.devops-private-route,
    local_file.ansible_inventory,
    tls_private_key.ssh_key
  ]

  tags = {
    Name      = "ansible-controller"
    Role      = "ansible"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_instance" "monitoring-server" {
  ami                         = data.aws_ami.ubuntu_24_04.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.devops-private-subnet.id
  vpc_security_group_ids      = [aws_security_group.devops-private-sg.id]
  private_ip                  = "10.0.0.136"
  key_name                    = aws_key_pair.ansible.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name      = "monitoring-server"
    Role      = "monitoring"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}
