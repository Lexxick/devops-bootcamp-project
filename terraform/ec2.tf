data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  private_ip    = "10.0.0.5"

  vpc_security_group_ids = [aws_security_group.public.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  user_data_replace_on_change = true
  user_data_base64 = base64encode(templatefile("${path.module}/user_data_node.sh", {
    public_key = tls_private_key.ansible.public_key_openssh
  }))

  tags = { Name = "web-server" }
}

resource "aws_eip" "web" {
  domain = "vpc"
}

resource "aws_eip_association" "web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}

resource "aws_instance" "ansible" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  private_ip    = "10.0.0.135"

  vpc_security_group_ids = [aws_security_group.private.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  user_data_replace_on_change = true
  user_data_base64 = base64encode(templatefile("${path.module}/user_data_controller.sh", {
  private_key           = tls_private_key.ansible.private_key_pem
  web_private_ip        = aws_instance.web.private_ip
  monitoring_private_ip = aws_instance.monitoring.private_ip
}))

  tags = { Name = "ansible-controller" }
}

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  private_ip    = "10.0.0.136"

  vpc_security_group_ids = [aws_security_group.private.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  user_data_replace_on_change = true
  user_data_base64 = base64encode(templatefile("${path.module}/user_data_node.sh", {
    public_key = tls_private_key.ansible.public_key_openssh
  }))

  tags = { Name = "monitoring-server" }
}
