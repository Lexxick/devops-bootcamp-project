#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

echo "Waiting for outbound network..."
for i in $(seq 1 60); do
  if curl -4 -m 3 -fsS http://1.1.1.1 >/dev/null 2>&1; then
    echo "Network OK"
    break
  fi
  echo "Network not ready ($i/60). Sleeping 5s..."
  sleep 5
done

apt-get update -y
apt-get install -y git python3-pip ansible

mkdir -p /home/ubuntu/.ansible

# ---- Write SSH private key used to reach the nodes ----
cat > /home/ubuntu/.ansible/ansible_key.pem <<'KEY_EOF'
${private_key}
KEY_EOF

chmod 600 /home/ubuntu/.ansible/ansible_key.pem
chown -R ubuntu:ubuntu /home/ubuntu/.ansible

# ---- Write inventory (from Terraform) ----
cat > /home/ubuntu/.ansible/inventory.ini <<'INV_EOF'
[web]
web-server ansible_host=${web_private_ip}

[monitoring]
monitoring-server ansible_host=${monitoring_private_ip}

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ansible/ansible_key.pem
ansible_python_interpreter=/usr/bin/python3
INV_EOF

chown ubuntu:ubuntu /home/ubuntu/.ansible/inventory.ini

# ---- Ansible config: avoid interactive host key prompts ----
cat > /home/ubuntu/.ansible/ansible.cfg <<'CFG_EOF'
[defaults]
inventory = /home/ubuntu/.ansible/inventory.ini
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
CFG_EOF

chown ubuntu:ubuntu /home/ubuntu/.ansible/ansible.cfg
chmod 644 /home/ubuntu/.ansible/ansible.cfg

echo "controller ready"
