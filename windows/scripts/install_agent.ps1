param (
    [string]$AgentInstaller = "C:\packages\wazuh-agent-4.12.0-1.msi"
)

Write-Host "[INFO] Installing Wazuh Agent: $AgentInstaller"
Start-Process msiexec.exe -ArgumentList "/i", "`"$AgentInstaller`"", "/qn" -Wait

Write-Host "[INFO] Starting Wazuh Agent service..."
Start-Service WazuhSvc
Set-Service WazuhSvc -StartupType Automatic
