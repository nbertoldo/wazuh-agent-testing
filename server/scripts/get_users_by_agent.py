import requests
from requests.auth import HTTPBasicAuth
import json
import sys
import os

# Validate command line arguments
if len(sys.argv) != 2:
    print("Usage: python3 get_users_by_agent.py <agent_id>")
    sys.exit(1)

agent_id = sys.argv[1]

# Configuration
wazuh_indexer_url = "https://192.168.56.30:9200"
index_pattern = "wazuh-states-inventory-users-vm-ubuntu2204-server*"
username = "admin"
password = "admin"
verify_ssl = False  # Change to True if you have a valid SSL certificate

# Deactivate SSL warnings (not recommended for production)
requests.packages.urllib3.disable_warnings()

# Build the URL for the Wazuh Indexer API
url = f"{wazuh_indexer_url}/{index_pattern}/_search"

payload = {
    "query": {
        "term": {
            "agent.id": {
                "value": agent_id
            }
        }
    },
    "size": 1000  # Change this value to adjust the number of results returned
}

try:
    response = requests.get(
        url,
        auth=HTTPBasicAuth(username, password),
        headers={"Content-Type": "application/json"},
        data=json.dumps(payload),
        verify=verify_ssl
    )

    if response.status_code == 200:
        result = response.json()
        hits = result.get("hits", {}).get("hits", [])

        print(f"{len(hits)} events found for agent {agent_id}.\n")

        filename = f"inventory_user_events_{agent_id}.json"
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(result, f, indent=4, ensure_ascii=False)

        print(f"Events saved in {filename}\n")
    else:
        print(f"Failed to retrieve events for agent {agent_id}. Status code: {response.status_code}")
        print(response.text)

except Exception as e:
    print(f"Error occurred connecting to wazuh indexer: {e}")
