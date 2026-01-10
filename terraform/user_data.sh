#!/bin/bash
#Version 1.4
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Force apt to use IPv4
cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

export DEBIAN_FRONTEND=noninteractive

# ---- Wait for outbound network (NAT may not be ready at first boot) ----
echo "Waiting for outbound network via NAT..."
for i in $(seq 1 60); do
  if curl -4 -m 3 -fsS http://1.1.1.1 >/dev/null 2>&1; then
    echo "Outbound network is up."
    break
  fi
  echo "Network not ready yet ($i/60). Sleeping 5s..."
  sleep 5
done

# ---- Apt update/install with retries ----
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

echo "Installing packages..."
for i in $(seq 1 5); do
  if apt-get install -y git python3-pip ansible; then
    echo "Package install succeeded."
    break
  fi
  echo "Package install failed ($i/5). Sleeping 10s..."
  sleep 10
done

# ---- Write Ansible inventory + key on the controller ----
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
