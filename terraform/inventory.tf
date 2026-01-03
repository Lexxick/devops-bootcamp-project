resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    # 1. Pass the individual resources for specific group referencing
    web_server         = aws_instance.web-server
    ansible_controller = aws_instance.ansible-controller
    monitoring_server  = aws_instance.monitoring-server
    
    # 2. Keep the instances list if your template loops through everything
    instances = [
      aws_instance.web-server,
      aws_instance.ansible-controller,
      aws_instance.monitoring-server
    ]
    
    ssh_private_key = local_file.private_key_pem.filename
  })
  filename = "${path.module}/inventory.ini"
}
