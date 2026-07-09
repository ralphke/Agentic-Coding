<#
.SYNOPSIS
Builds or starts the devcontainer using a selected Dockerfile target.

.DESCRIPTION
This script is an optional manual helper. The primary VS Code devcontainer entrypoint
is .devcontainer/devcontainer.json, so prefer that path for normal use.
Sets DOCKERFILE_TARGET for the current process, runs docker compose with
.devcontainer/docker-compose.yml, and restores the previous environment value.

.PARAMETER Target
Predefined Dockerfile target: security-fix or custom.

.PARAMETER CustomDockerfile
Dockerfile name or path used when -Target custom is selected.

.PARAMETER Up
Runs 'docker compose up --build' instead of 'docker compose build'.

.PARAMETER NoCache
Adds '--no-cache' to the compose command.

.EXAMPLE
pwsh -ExecutionPolicy Bypass -File .devcontainer/build-with-dockerfile.ps1 -Target security-fix

.EXAMPLE
pwsh -ExecutionPolicy Bypass -File .devcontainer/build-with-dockerfile.ps1 -Target custom -CustomDockerfile Dockerfile -Up
#>
param(
    [ValidateSet("security-fix", "custom")]
    [string]$Target = "security-fix",
    [string]$CustomDockerfile,
    [switch]$Up,
    [switch]$NoCache
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$composePath = Join-Path $PSScriptRoot "docker-compose.yml"

if (-not (Test-Path -LiteralPath $composePath)) {
    Write-Error "Compose file not found: $composePath"
    exit 1
}

switch ($Target) {
    "security-fix" { $dockerfile = "Dockerfile.security-fix" }
    "custom" {
        if ([string]::IsNullOrWhiteSpace($CustomDockerfile)) {
            Write-Error "When Target is 'custom', provide -CustomDockerfile with a Dockerfile name or path."
            exit 1
        }
        $dockerfile = $CustomDockerfile
    }
}

$dockerfilePath = Join-Path $PSScriptRoot $dockerfile
if (-not (Test-Path -LiteralPath $dockerfilePath)) {
    Write-Error "Dockerfile not found: $dockerfilePath"
    exit 1
}

$previousTarget = [System.Environment]::GetEnvironmentVariable("DOCKERFILE_TARGET", "Process")
$pushedLocation = $false

try {
    [System.Environment]::SetEnvironmentVariable("DOCKERFILE_TARGET", $dockerfile, "Process")

    $dockerArgs = @("compose", "-f", $composePath)
    if ($Up) {
        $dockerArgs += @("up", "--build")
    } else {
        $dockerArgs += "build"
    }

    if ($NoCache) {
        $dockerArgs += "--no-cache"
    }

    Write-Host "Using DOCKERFILE_TARGET=$dockerfile"
    Write-Host ("Running: docker " + ($dockerArgs -join " "))

    Push-Location $repoRoot
    $pushedLocation = $true

    & docker @dockerArgs
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    if ($pushedLocation) {
        Pop-Location
    }

    if ($null -eq $previousTarget) {
        Remove-Item Env:\DOCKERFILE_TARGET -ErrorAction SilentlyContinue
    } else {
        [System.Environment]::SetEnvironmentVariable("DOCKERFILE_TARGET", $previousTarget, "Process")
    }
}
