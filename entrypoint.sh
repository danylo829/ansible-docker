#!/bin/sh
set -euo pipefail

if [ -f "requirements.yml" ]; then
  echo "Installing Ansible Galaxy deps..."
  ansible-galaxy collection install -r requirements.yml || true
  ansible-galaxy role install -r requirements.yml || true
fi

if [ -f "requirements.txt" ]; then
  echo "Installing pip packages..."
  python3 -m pip install --break-system-packages -r requirements.txt
fi

exec "$@"
