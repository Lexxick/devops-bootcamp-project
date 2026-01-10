resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    web_private_ip        = aws_instance.web-server.private_ip
    monitoring_private_ip = aws_instance.monitoring-server.private_ip
    ssh_user              = "ubuntu"
  })

  filename = "${path.module}/inventory.ini"
}
