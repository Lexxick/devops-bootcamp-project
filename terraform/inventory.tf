resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    web_server         = aws_instance.web-server
    ansible_controller = aws_instance.ansible-controller
    monitoring_server  = aws_instance.monitoring-server
    ssh_private_key    = local_file.private_key_pem.filename
  })
  filename = "../ansible/inventory.ini"
}
