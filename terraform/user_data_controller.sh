#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Make apt more reliable on first boot (NAT sometimes slow)
cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

export DEBIAN_FRONTEND=noninteractive

# Wait for outbound net
for i in $(seq 1 60); do
  if curl -4 -m 3 -fsS http://1.1.1.1 >/dev/null 2>&1; then break; fi
  sleep 5
done

apt-get update -y
apt-get install -y ansible git

# Write inventory + key for ubuntu user
mkdir -p /home/ubuntu/.ansible

cat > /home/ubuntu/.ansible/inventory.ini <<'EOF'
[web]
web-server ansible_host=10.0.0.5

[monitoring]
monitoring-server ansible_host=10.0.0.136

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ansible/ansible_key.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

cat > /home/ubuntu/.ansible/ansible_key.pem <<'EOF'
${private_key}
EOF

chmod 600 /home/ubuntu/.ansible/ansible_key.pem
chown -R ubuntu:ubuntu /home/ubuntu/.ansible
