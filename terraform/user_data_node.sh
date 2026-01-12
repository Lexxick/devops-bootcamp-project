#!/bin/bash
# node: web/monitoring
set -euxo pipefail
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

# Force apt to use IPv4 (avoids IPv6 "network unreachable" issues)
cat >/etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
Acquire::ForceIPv4 "true";
EOF

# Wait for outbound internet (NAT/public route might not be ready)
for i in $(seq 1 60); do
  if curl -4 -m 3 -fsS http://1.1.1.1 >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

# Install basics + Docker
apt-get clean
apt-get update -y
apt-get install -y ca-certificates curl gnupg git

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

# Allow ubuntu user to run docker without sudo
usermod -aG docker ubuntu || true

# Add controller public key to ubuntu authorized_keys
install -d -m 0700 /home/ubuntu/.ssh
cat >> /home/ubuntu/.ssh/authorized_keys <<'EOF'
${public_key}
EOF
chmod 0600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
