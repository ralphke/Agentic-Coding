param(
    [string]$LocalImage = "agentic-coding-image:latest",
    [string]$ImageName = "agentic-coding-image",
    [string]$Tag = "latest",
    [string]$Owner,
    [string]$Actor = $env:GITHUB_ACTOR,
    [string]$Token = $env:GITHUB_TOKEN,
    [switch]$PushShaTag,
    [string]$ShaTag = $env:GITHUB_SHA
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-GitHubOwner {
    if ($env:GITHUB_REPOSITORY -and $env:GITHUB_REPOSITORY.Contains("/")) {
        return $env:GITHUB_REPOSITORY.Split("/")[0].ToLowerInvariant()
    }

    $origin = ""
    try {
        $origin = (git remote get-url origin).Trim()
    }
    catch {
        return $null
    }

    if (-not $origin) {
        return $null
    }

    # Supports:
    #   https://github.com/owner/repo.git
    #   git@github.com:owner/repo.git
    $m = [regex]::Match($origin, "github\.com[:/](?<owner>[^/]+)/(?<repo>[^/.]+)(\.git)?$")
    if ($m.Success) {
        return $m.Groups["owner"].Value.ToLowerInvariant()
    }

    return $null
}

function Get-GitHubToken {
    param([string]$ExistingToken)

    if ($ExistingToken) {
        return $ExistingToken
    }

    $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghCmd) {
        try {
            $ghToken = (gh auth token).Trim()
            if ($ghToken) {
                return $ghToken
            }
        }
        catch {
            # Fallback to explicit error below when no token is available.
        }
    }

    return $null
}

function Test-GhWritePackagesScope {
    $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $ghCmd) {
        return $false
    }

    try {
        $raw = gh api -i user 2>$null
        if (-not $raw) {
            return $false
        }

        $scopeLine = ($raw | Select-String '^x-oauth-scopes:' | Select-Object -First 1)
        if (-not $scopeLine) {
            return $false
        }

        return ($scopeLine.Line -match 'write:packages')
    }
    catch {
        return $false
    }
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI was not found in PATH."
}

if (-not $Owner) {
    $Owner = Get-GitHubOwner
}

if (-not $Owner) {
    throw "Could not determine GitHub owner. Pass -Owner <github-owner> or set GITHUB_REPOSITORY."
}

if (-not $Actor) {
    $Actor = $Owner
}

$Token = Get-GitHubToken -ExistingToken $Token
if (-not $Token) {
    throw "No GitHub token found. Set GITHUB_TOKEN or sign in with GitHub CLI (gh auth login)."
}

if (-not $env:GITHUB_TOKEN) {
    # Script is using gh auth token fallback. Ensure package push scope exists.
    if (-not (Test-GhWritePackagesScope)) {
        throw "The active gh auth token is missing 'write:packages'. Re-auth with: gh auth refresh -h github.com -s write:packages,read:packages,repo or set GITHUB_TOKEN to a PAT that includes write:packages."
    }
}

# Validate the local image exists before login/tag/push.
docker image inspect $LocalImage *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Local image '$LocalImage' was not found. Build it first."
}

$target = "ghcr.io/$($Owner.ToLowerInvariant())/${ImageName}:$Tag"

Write-Host "Logging in to GHCR as '$Actor'..."
$Token | docker login ghcr.io -u $Actor --password-stdin
if ($LASTEXITCODE -ne 0) {
    throw "Docker login to GHCR failed."
}

Write-Host "Tagging $LocalImage as $target"
docker tag $LocalImage $target
if ($LASTEXITCODE -ne 0) {
    throw "Failed to tag image '$LocalImage' as '$target'."
}

Write-Host "Pushing $target"
docker push $target
if ($LASTEXITCODE -ne 0) {
    throw "Failed to push '$target'. If you see 403 Forbidden, ensure token scope includes write:packages and read:packages, and that package publishing is allowed for this account/org."
}

if ($PushShaTag) {
    if (-not $ShaTag) {
        throw "-PushShaTag was set but no SHA tag is available. Pass -ShaTag <value> or set GITHUB_SHA."
    }

    $shaTarget = "ghcr.io/$($Owner.ToLowerInvariant())/${ImageName}:$ShaTag"
    Write-Host "Tagging $LocalImage as $shaTarget"
    docker tag $LocalImage $shaTarget
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to tag image '$LocalImage' as '$shaTarget'."
    }

    Write-Host "Pushing $shaTarget"
    docker push $shaTarget
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push '$shaTarget'. If you see 403 Forbidden, ensure token scope includes write:packages and read:packages, and that package publishing is allowed for this account/org."
    }
}

Write-Host ""
Write-Host "Push complete."
Write-Host "Primary tag: $target"
if ($PushShaTag) {
    Write-Host "SHA tag: ghcr.io/$($Owner.ToLowerInvariant())/${ImageName}:$ShaTag"
}
