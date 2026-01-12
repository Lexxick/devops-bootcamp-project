#!/bin/bash
# controller: ansible
set -euxo pipefail
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

# Force apt to use IPv4
cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

# Wait for outbound internet
for i in $(seq 1 60); do
  if curl -4 -m 3 -fsS http://1.1.1.1 >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

apt-get clean
apt-get update -y
apt-get install -y git python3-pip ansible

# Write key + inventory for ubuntu user
mkdir -p /home/ubuntu/.ansible

cat > /home/ubuntu/.ansible/ansible_key.pem <<'KEY_EOF'
${private_key}
KEY_EOF
chmod 600 /home/ubuntu/.ansible/ansible_key.pem
chown -R ubuntu:ubuntu /home/ubuntu/.ansible

# Inventory points to your private IPs
cat > /home/ubuntu/.ansible/inventory.ini <<'INV_EOF'
[web]
web-server ansible_host=10.0.0.5

[monitoring]
monitoring-server ansible_host=10.0.0.136

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ansible/ansible_key.pem
ansible_python_interpreter=/usr/bin/python3
INV_EOF
chown ubuntu:ubuntu /home/ubuntu/.ansible/inventory.ini

echo "controller ready"
