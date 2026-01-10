#!/bin/bash
#Version 1.3
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# --- Fix: force apt to use IPv4 (your apt was resolving IPv6 first and failing) ---
cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

export DEBIAN_FRONTEND=noninteractive

# --- Update + install deps (retry once to handle mirror hiccups) ---
apt-get clean
apt-get update -y || apt-get update -y
apt-get install -y git python3-pip ansible

# --- Write Ansible inventory + key on the controller ---
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
