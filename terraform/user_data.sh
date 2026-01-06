#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y
apt-get install -y git python3-pip ansible

mkdir -p /home/ssm-user/.ansible

cat > /home/ssm-user/.ansible/inventory.ini <<'INVENTORY_EOF'
${inventory_content}
INVENTORY_EOF

cat > /home/ssm-user/.ansible/ansible_key.pem <<'KEY_EOF'
${key_content}
KEY_EOF

chmod 600 /home/ssm-user/.ansible/ansible_key.pem
chown -R ssm-user:ssm-user /home/ssm-user/.ansible

echo "ansible files written"