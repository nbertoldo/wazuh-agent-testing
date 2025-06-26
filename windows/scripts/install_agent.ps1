param (
    [string]$AgentInstaller = "C:\packages\wazuh-agent-4.12.0-1.msi",
    [string]$ManagerIP = "10.0.0.2"
)

Write-Host "[INFO] Installing Wazuh Agent: $AgentInstaller"
Start-Process msiexec.exe -ArgumentList "/i", "`"$AgentInstaller`"", "WAZUH_MANAGER=$ManagerIP", "/qn" -Wait

Write-Host "[INFO] Starting Wazuh Agent service..."
Start-Service WazuhSvc
Set-Service WazuhSvc -StartupType Automatic
