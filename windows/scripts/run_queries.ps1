param (
    [string]$QueryFile = "C:\queries\osquery_queries.conf",
    [string]$OutputFile = "C:\results\osquery_results_$(hostname).json"
)

$osqueryi = "C:\Program Files\osquery\osqueryi.exe"

if (-Not (Test-Path $osqueryi)) {
    Write-Host "[ERROR] osqueryi.exe not found at $osqueryi"
    exit 1
}

if (-Not (Test-Path $QueryFile)) {
    Write-Host "[ERROR] Query file not found: $QueryFile"
    exit 1
}

$results = @()
Get-Content $QueryFile | ForEach-Object {
    $query = $_.Trim()
    if ($query -and -not $query.StartsWith("--")) {
        Write-Host "[INFO] Running query: $query"
        $output = & "$osqueryi" --json "$query" | ConvertFrom-Json
        $results += [PSCustomObject]@{
            query   = $query
            results = $output
        }
    }
}

$results | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
Write-Host "[INFO] Results written to $OutputFile"
