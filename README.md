# Wazuh Agent Testing Environment

This repository provides a cross-platform testing environment for Wazuh agents using [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/). It allows automated provisioning of virtual machines (VMs), Wazuh agent installation, osquery deployment, and execution of custom queries, with results saved locally for analysis.

## 📦 Repository Structure

```pgsql
wazuh-agent-testing/
├── common/ # Shared scripts across all platforms
├── debian/ # Debian/Ubuntu environment
| ├── config/ # Configuration file ossec.conf
│ ├── packages/ # Wazuh agent .deb packages
│ ├── queries/ # osquery queries file
│ ├── scripts/ # Scripts
│ └── Vagrantfile
├── redhat/ # RHEL/CentOS/Fedora/Amazon Linux environment
├── windows/ # Windows Server/Workstation environment
├── macos/ # macOS environment
├── results/ # Directory to store testing results
├── server/ # Scripts to be used in the server
└── README.md # This file
```

Each platform has:
- Its own `Vagrantfile`
- A `config/` folder for agent configuration file
- A `packages/` folder for Wazuh agent installers
- A `queries/` folder for osquery queries
- A `scripts/` folder for provisioning

---

## 🚀 How to Use

### 1. Place the Wazuh Agent Package

Place the Wazuh agent installer in the appropriate `packages/` subdirectory depending on the platform:

| Platform   | Package Format         | Directory Example                  |
|------------|------------------------|------------------------------------|
| Debian     | `.deb`                 | `debian/packages/`                |
| RedHat     | `.rpm`                 | `redhat/packages/`                |
| Windows    | `.msi`                 | `windows/packages/`               |
| macOS      | `.pkg` (arm64/intel64) | `macos/packages/`                 |

> ✅ The latest `.deb`, `.rpm`, or `.msi` package found in the `packages/` directory is automatically selected for installation. Make sure to remove outdated versions if necessary.

---

### 2. Configure the Wazuh Manager Address

The agent installation script replaces the default `ossec.conf` file with the one located in the corresponding `config/` directory depending on the platform.

Before starting the agent, the script applies this file, so any configuration changes, including the Wazuh manager IP address, must be made directly in this file.

Make sure to update the appropriate `ossec.conf` file for your platform with the desired manager IP and any other custom settings before provisioning the agent.

---

### 3. Define osquery Queries

Define the osquery queries you want to run inside the `osquery_queries.conf` file located in each platform’s `queries/` directory.

Example query file (`queries/osquery_queries.conf`):

```sql
SELECT * FROM os_version;
SELECT name, uid FROM users WHERE shell != '/usr/sbin/nologin';
```

---

### 4. Launch the VM(s)

Navigate to the target platform directory (e.g., `debian/`, `redhat/`, `windows/`) and run:

```bash
vagrant up [vm_name]
```

This process will:

- Start the VM.
- Install the Wazuh agent using the detected package.
- Install osquery (downloaded automatically if missing on Windows).
- Run the queries defined in `osquery_queries.conf`.

---

### 5. Access the Results

Once the VM completes provisioning, results will be written to the shared `results/` directory at the root of the project.

Each VM will generate a JSON file:

```pgsql
results/
├── system_info_ubuntu2204.json
├── system_info_rhel9.wazuh.test.json
├── system_info_win2022-wazuh-test.json
```

The filename reflects the hostname of the machine for easy identification.

---

## 🔁 Rerunning Tests

To rerun a VM from scratch:

```bash
vagrant destroy -f [vm_name] && vagrant up [vm_name]
```

## 🧹 Clean Up

To shut down and remove virtual machines:

```bash
vagrant destroy -f [vm_name]
```