# Wazuh Agent Testing Environment

This repository provides a cross-platform testing environment for Wazuh agents using [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/). It allows automated provisioning of virtual machines (VMs), Wazuh agent installation, osquery deployment, and execution of custom queries, with results saved locally for analysis.

## 📦 Repository Structure

```pgsql
wazuh-agent-testing/
├── common/ # Shared scripts across all platforms
├── debian/ # Debian/Ubuntu environment
│ ├── packages/ # Wazuh agent .deb packages
│ ├── queries/ # osquery queries file
│ ├── scripts/ # Scripts
│ └── Vagrantfile
├── redhat/ # RHEL/CentOS/Fedora/Amazon Linux environment
├── windows/ # Windows Server/Workstation environment
├── macos/ # macOS environment
├── results/ # Directory to store testing results
└── README.md # This file
```

Each platform has:
- Its own `Vagrantfile`
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

### 2. Define osquery Queries

Define the osquery queries you want to run inside the `osquery_queries.conf` file located in each platform’s `queries/` directory.

Example query file (`queries/osquery_queries.conf`):

```sql
SELECT * FROM os_version;
SELECT name, uid FROM users WHERE shell != '/usr/sbin/nologin';
```

---

### 3. Configure the Wazuh Manager Address

The Wazuh agent is configured automatically to connect to the Wazuh manager using the IP address provided by the `WAZUH_MANAGER_IP` environment variable:

```bash
export WAZUH_MANAGER_IP=192.168.56.30
```

Or set the IP address editing the `Vagrantfile`.

```ruby
MANAGER_IP = ENV['WAZUH_MANAGER_IP'] || "192.168.56.30"
```

---

### 4. Launch the VM(s)

Navigate to the target platform directory (e.g., `debian/`, `redhat/`, `windows/`) and run:

```bash
vagrant up
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
├── osquery_results_ubuntu2204.json
├── osquery_results_rhel9.wazuh.test.json
├── osquery_results_win2022-wazuh-test.json
```

The filename reflects the hostname of the machine for easy identification.

---

## 🔁 Rerunning Tests

To rerun a VM from scratch:

```bash
vagrant destroy -f && vagrant up
```

## 🧹 Clean Up

To shut down and remove all virtual machines:

```bash
vagrant destroy -f
```