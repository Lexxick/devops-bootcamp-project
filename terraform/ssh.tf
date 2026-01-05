resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  # Saves the key in your ansible/ directory relative to where you run terraform
  filename        = "../ansible/ansible-key.pem" 
  file_permission = "0400"
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
