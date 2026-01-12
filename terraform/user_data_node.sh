#!/bin/bash
set -euxo pipefail

mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

cat >> /home/ubuntu/.ssh/authorized_keys <<'EOF'
${public_key}
EOF

chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
