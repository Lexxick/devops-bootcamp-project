resource "tls_private_key" "ansible" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
