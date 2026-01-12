#!/bin/bash
# user_data_node.sh
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

# Force apt to use IPv4 (helps when IPv6 egress is flaky)
cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

# Wait for basic outbound connectivity (NAT can take a bit)
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

# Install Docker (simple, official Ubuntu repo)
echo "Installing docker..."
for i in $(seq 1 5); do
  if apt-get install -y docker.io; then
    echo "Docker install succeeded."
    break
  fi
  echo "Docker install failed ($i/5). Sleeping 10s..."
  sleep 10
done

systemctl enable --now docker

# Allow ubuntu user to run docker without sudo (effective after re-login)
usermod -aG docker ubuntu || true

# Add the controller's SSH public key to ubuntu authorized_keys
install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.ssh
touch /home/ubuntu/.ssh/authorized_keys
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys

# Terraform will substitute this line with the public key string
echo '${public_key}' >> /home/ubuntu/.ssh/authorized_keys

# De-duplicate authorized_keys (keep it clean if user-data reruns)
awk '!seen[$0]++' /home/ubuntu/.ssh/authorized_keys > /home/ubuntu/.ssh/authorized_keys.tmp
mv /home/ubuntu/.ssh/authorized_keys.tmp /home/ubuntu/.ssh/authorized_keys
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys

echo "node ready"
