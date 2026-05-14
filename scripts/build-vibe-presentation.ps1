param(
    [string]$SourcesPath = "$PSScriptRoot\..\resources\vibecoding",
    [string]$OutputPath = "$PSScriptRoot\..\build\vibe-to-live-deck.pptx",
    [string]$ReferenceTemplatePath = "$PSScriptRoot\..\build\pandoc-default-reference.pptx"
)

$SourcesPath = Resolve-Path -Path $SourcesPath
$outputDir = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$referenceDir = Split-Path -Path $ReferenceTemplatePath -Parent
if (-not (Test-Path -Path $referenceDir)) {
    New-Item -ItemType Directory -Path $referenceDir -Force | Out-Null
}

if (-not (Test-Path -Path $ReferenceTemplatePath)) {
    Write-Host "Exporting Pandoc default PPTX reference template..." -ForegroundColor Cyan
    $pandocRef = & pandoc --print-default-data-file reference.pptx
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($pandocRef)) {
        Write-Error "Unable to locate Pandoc default reference template."
        exit 1
    }
    $pandocRef = $pandocRef.Trim()
    Copy-Item -Path $pandocRef -Destination $ReferenceTemplatePath -Force
}

$files = Get-ChildItem -Path $SourcesPath -Filter '*.md' | Where-Object { $_.Name -ne 'README.md' } | Sort-Object Name
if (-not $files) {
    Write-Error "No markdown files found in '$SourcesPath'."
    exit 1
}

$outputFile = $OutputPath

Write-Host "Rendering PowerPoint deck from markdown sources:" -ForegroundColor Cyan
$files | ForEach-Object { Write-Host " - $($_.Name)" }
Write-Host "Using local Pandoc reference template: $ReferenceTemplatePath" -ForegroundColor Cyan
Write-Host "Output: $outputFile"

pandoc @($files.FullName) -t pptx --reference-doc "$ReferenceTemplatePath" --slide-level=2 -o "$outputFile"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Created PowerPoint deck:" -ForegroundColor Green
    Write-Host "  $outputFile"
} else {
    Write-Error "Pandoc failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
