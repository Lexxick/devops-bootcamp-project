#!/bin/bash
#Version 1.2
set -euxo pipefail
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y
apt-get install -y git python3-pip ansible

mkdir -p /home/ubuntu/.ansible

cat > /home/ubuntu/.ansible/inventory.ini <<'INVENTORY_EOF'
${inventory_content}
INVENTORY_EOF

cat > /home/ubuntu/.ansible/ansible_key.pem <<'KEY_EOF'
${key_content}
KEY_EOF

chmod 600 /home/ubuntu/.ansible/ansible_key.pem
chown -R ubuntu:ubuntu /home/ubuntu/.ansible

echo "ansible files written"
