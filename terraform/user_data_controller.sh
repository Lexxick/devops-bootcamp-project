#!/bin/bash
# user_data_controller.sh (simple + reliable)
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
  if timeout 3 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/80' 2>/dev/null; then
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

# Install Ansible
echo "Installing packages..."
for i in $(seq 1 5); do
  if apt-get install -y git python3-pip ansible openssh-client; then
    echo "Package install succeeded."
    break
  fi
  echo "Package install failed ($i/5). Sleeping 10s..."
  sleep 10
done

# Write SSH key for ubuntu user (so ansible can SSH to nodes)
install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.ssh

cat >/home/ubuntu/.ssh/ansible_key.pem <<'KEY_EOF'
${private_key}
KEY_EOF
chown ubuntu:ubuntu /home/ubuntu/.ssh/ansible_key.pem
chmod 600 /home/ubuntu/.ssh/ansible_key.pem

# Global ansible config + inventory (so "ansible all -m ping" works anywhere)
install -d -m 755 /etc/ansible

cat >/etc/ansible/hosts <<'INV_EOF'
[web]
web-server ansible_host=10.0.0.5

[monitoring]
monitoring-server ansible_host=10.0.0.136

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/ansible_key.pem
ansible_python_interpreter=/usr/bin/python3
INV_EOF
chmod 644 /etc/ansible/hosts

cat >/etc/ansible/ansible.cfg <<'CFG_EOF'
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent
timeout = 30

[ssh_connection]
pipelining = True
CFG_EOF
chmod 644 /etc/ansible/ansible.cfg

echo "controller ready"
