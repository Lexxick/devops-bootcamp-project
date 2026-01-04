resource "aws_ssm_document" "copy_inventory_to_ansible_controller" {
  name          = "copy-inventory-ini-to-ansible-controller"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Copy inventory.ini into ansible-controller repo"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "writeInventory"
        inputs = {
          runCommand = [
            "mkdir -p /home/ubuntu/devops-bootcamp-project/ansible",
            "cat <<'EOF' > /home/ubuntu/devops-bootcamp-project/ansible/inventory.ini",
            # FIX: Remove file() and quotes. Use the resource attribute directly.
            local_file.ansible_inventory.content, 
            "EOF"
          ]
        }
      }
    ]
  })
}

resource "aws_ssm_association" "run_inventory_copy" {
  name = aws_ssm_document.copy_inventory_to_ansible_controller.name

  targets {
    key    = "tag:Role"
    values = ["ansible"]
  }

  # This part is correct! It ensures the server and file exist first.
  depends_on = [
    local_file.ansible_inventory,
    aws_instance.ansible-controller
  ]
}


