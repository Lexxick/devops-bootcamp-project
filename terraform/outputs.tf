output "web_server_public_ip" {
  description = "The public IP address assigned to the web server (for DNS mapping)"
  value       = aws_eip.web_server_static_ip.public_ip
}

output "ansible_controller_ssm_command" {
  description = "Command to start an SSM session to the ansible controller"
  value       = "aws ssm start-session --target ${aws_instance.ansible-controller.id}"
}

output "ansible_inventory_file" {
  description = "Path to generated Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}

output "ansible_ssh_key_file" {
  description = "Path to generated private ssh key"
  value       = local_file.private_key_pem.filename
  sensitive   = false
}

