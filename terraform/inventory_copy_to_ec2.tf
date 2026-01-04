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
            # ensure directory exists (repo already cloned by user_data)
            "mkdir -p /home/ubuntu/devops-bootcamp-project/ansible",

            # write inventory.ini from Terraform local file content
            "cat <<'EOF' > /home/ubuntu/devops-bootcamp-project/ansible/inventory.ini",
            file("${path.module}/inventory.ini"),
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

  depends_on = [
    local_file.ansible_inventory,
    aws_instance.ansible-controller
  ]
}

