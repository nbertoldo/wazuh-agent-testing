#!/bin/bash

AGENT_PKG="$1"
MANAGER_IP="$2"

if [[ -z "$AGENT_PKG" || -z "$MANAGER_IP" ]]; then
  echo "Usage: $0 <package_path> <manager_ip>"
  exit 1
fi

# Export the Wazuh manager IP address
export WAZUH_MANAGER="$MANAGER_IP"

# Install the Wazuh agent package
echo "[INFO] Installing Wazuh agent: $AGENT_PKG"
WAZUH_MANAGER="$MANAGER_IP" yum install -y "$AGENT_PKG" || {
  echo "[ERROR] Failed to install $AGENT_PKG"
  exit 1
}

# Enable and start the Wazuh agent service
echo "[INFO] Enabling and starting wazuh-agent service..."
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent
