resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
