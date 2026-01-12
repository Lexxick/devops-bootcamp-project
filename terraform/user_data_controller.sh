#!/bin/bash
# user_data_controller.sh
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

# Force apt to use IPv4
cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

# Wait for outbound network
echo "Waiting for outbound network..."
for i in $(seq 1 60); do
  if curl -4 -m 3 -fsS http://1.1.1.1 >/dev/null 2>&1; then
    echo "Outbound network is up."
    break
  fi
  echo "Network not ready yet ($i/60). Sleeping 5s..."
  sleep 5
done

# apt update with retries
echo "Running apt-get update..."
for i in $(seq 1 10); do
  apt-get clean
  if apt-get update -y; then
    echo "apt-get update succeeded."
    break
  fi
  echo "apt-get update failed ($i/10). Sleeping 10s..."
  sleep 10
done

# Install Ansible + helpers
echo "Installing packages..."
for i in $(seq 1 5); do
  if apt-get install -y git python3-pip ansible; then
    echo "Package install succeeded."
    break
  fi
  echo "Package install failed ($i/5). Sleeping 10s..."
  sleep 10
done

# Write Ansible key + inventory + config
install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.ansible

cat >/home/ubuntu/.ansible/ansible_key.pem <<'KEY_EOF'
${private_key}
KEY_EOF
chown ubuntu:ubuntu /home/ubuntu/.ansible/ansible_key.pem
chmod 600 /home/ubuntu/.ansible/ansible_key.pem

cat >/home/ubuntu/.ansible/inventory.ini <<'INV_EOF'
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
chmod 644 /home/ubuntu/.ansible/inventory.ini

# Disable host key prompt (beginner-friendly)
cat >/home/ubuntu/.ansible/ansible.cfg <<'CFG_EOF'
[defaults]
inventory = /home/ubuntu/.ansible/inventory.ini
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent
stdout_callback = yaml

[ssh_connection]
pipelining = True
CFG_EOF
chown ubuntu:ubuntu /home/ubuntu/.ansible/ansible.cfg
chmod 644 /home/ubuntu/.ansible/ansible.cfg

echo "controller ready"

