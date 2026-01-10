output "web_server_public_ip" {
  description = "Web server Elastic IP (use this for Cloudflare DNS A record web.yourdomain.com)"
  value       = aws_eip.web_server_static_ip.public_ip
}

output "ansible_controller_ssm_command" {
  description = "SSM session command to access the Ansible controller"
  value       = "aws ssm start-session --target ${aws_instance.ansible-controller.id}"
}

output "ansible_inventory_file" {
  description = "Local path to generated inventory.ini (Terraform side)"
  value       = local_file.ansible_inventory.filename
}

output "ansible_controller_inventory_path" {
  description = "Inventory path written on the Ansible controller by user_data"
  value       = "/home/ubuntu/.ansible/inventory.ini"
}

output "ansible_controller_key_path" {
  description = "SSH private key path written on the Ansible controller by user_data"
  value       = "/home/ubuntu/.ansible/ansible_key.pem"
  sensitive   = false
}

