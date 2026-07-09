param(
    [string]$Image = "agentic-coding-image:latest",
    [string]$Severity = "critical,high"
)

docker scout cves --only-severity $Severity "local://$Image"
exit $LASTEXITCODE