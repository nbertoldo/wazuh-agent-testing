$osqueryInstallerPath = "C:\packages\osquery-5.17.0.msi"
$osqueryDownloadURL = "https://pkg.osquery.io/windows/osquery-5.17.0.msi"

# Create directory if it does not exist
$packageDir = Split-Path -Path $osqueryInstallerPath
if (-Not (Test-Path $packageDir)) {
    New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
}

# Download osquery installer if it does not exist
if (-Not (Test-Path $osqueryInstallerPath)) {
    Write-Host "[INFO] osquery installer not found, downloading from $osqueryDownloadURL..."
    try {
        Invoke-WebRequest -Uri $osqueryDownloadURL -OutFile $osqueryInstallerPath -UseBasicParsing
        Write-Host "[INFO] Downloaded osquery installer to $osqueryInstallerPath"
    } catch {
        Write-Host "[ERROR] Failed to download osquery installer: "
        Write-Host $_.Exception.Message
        exit 1
    }
}

# Install osquery
Write-Host "[INFO] Installing osquery..."
Start-Process msiexec.exe -ArgumentList "/i", "`"$osqueryInstallerPath`"", "/qn" -Wait

