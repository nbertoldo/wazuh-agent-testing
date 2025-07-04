#!/bin/bash

AGENT_PKG="$1"

if [[ -z "$AGENT_PKG" ]]; then
  echo "Usage: $0 <package_path>"
  exit 1
fi

# Install the Wazuh agent package
echo "[INFO] Installing Wazuh agent: $AGENT_PKG"
yum install -y "$AGENT_PKG" || {
  echo "[ERROR] Failed to install $AGENT_PKG"
  exit 1
}

# Apply custom ossec.conf if exists
CUSTOM_CONF="/vagrant/config/ossec.conf"
OSSEC_CONF="/var/ossec/etc/ossec.conf"

if [[ -f "$CUSTOM_CONF" ]]; then
  echo "[INFO] Applying custom ossec.conf from $CUSTOM_CONF"
  cp "$CUSTOM_CONF" "$OSSEC_CONF"
else
  echo "[INFO] No custom ossec.conf provided. Using default configuration."
fi

# Enable and start the Wazuh agent service
echo "[INFO] Enabling and starting wazuh-agent service..."
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent
