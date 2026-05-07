param(
    [string]$EnvFile = ".devcontainer/.env.local",
    [switch]$ProcessOnly
)

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $root $EnvFile

if (-not (Test-Path -LiteralPath $envPath)) {
    $examplePath = "$envPath.example"
    if (Test-Path -LiteralPath $examplePath) {
        Copy-Item -LiteralPath $examplePath -Destination $envPath
        Write-Host "Created $envPath from example. Edit it with your local values and re-run this task."
    } else {
        Write-Error "Environment file not found: $envPath"
        exit 1
    }
    exit 0
}

$entries = Get-Content -LiteralPath $envPath
$applied = 0

foreach ($line in $entries) {
    $trimmed = $line.Trim()

    if ([string]::IsNullOrWhiteSpace($trimmed)) {
        continue
    }

    if ($trimmed.StartsWith("#")) {
        continue
    }

    $parts = $trimmed -split "=", 2
    if ($parts.Count -ne 2) {
        Write-Warning "Skipping malformed line: $line"
        continue
    }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim()

    if ([string]::IsNullOrWhiteSpace($key)) {
        Write-Warning "Skipping line with empty key: $line"
        continue
    }

    [System.Environment]::SetEnvironmentVariable($key, $value, "Process")

    if (-not $ProcessOnly) {
        [System.Environment]::SetEnvironmentVariable($key, $value, "User")
    }

    $applied++
    Write-Host "Set $key"
}

if ($ProcessOnly) {
    Write-Host "Applied $applied variables to current PowerShell process only."
    Write-Host "Note: VS Code must read host environment before opening/rebuilding container."
} else {
    Write-Host "Applied $applied variables to current process and user environment."
    Write-Host "Restart VS Code before rebuilding/reopening the dev container."
}
