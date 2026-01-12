#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

# Force apt to use IPv4 (helps in some NAT/DNS edge cases)
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
apt-get install -y ca-certificates curl gnupg

# ---- Install Docker (official repo) ----
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

systemctl enable --now docker

# Allow ubuntu user to run docker without sudo
usermod -aG docker ubuntu || true

# ---- Add controller public key for SSH ----
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

# Replace file content with exactly 1 key (clean + predictable)
cat > /home/ubuntu/.ssh/authorized_keys <<'KEY_EOF'
${public_key}
KEY_EOF

chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

echo "node ready"
