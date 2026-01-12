output "web_public_ip" {
  value = aws_eip.web.public_ip
}

output "ansible_ssm" {
  value = "aws ssm start-session --target ${aws_instance.ansible.id}"
}
