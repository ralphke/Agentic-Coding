#!/usr/bin/env bash
# ============================================================================
# DevContainer Security Scan — Local CVE Scanning
# ============================================================================
# 
# Usage:
#   bash .devcontainer/scan-cves.sh          # Run Docker Scout
#   bash .devcontainer/scan-cves.sh --trivy  # Run Trivy instead
#   bash .devcontainer/scan-cves.sh --full   # Run both
#
# Prerequisites:
#   - Docker Desktop with Docker Scout enabled
#   - OR Trivy installed locally (https://github.com/aquasecurity/trivy)
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="agentic-workshop:scan"
REPORT_DIR="${SCRIPT_DIR}/security-reports"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

mkdir -p "$REPORT_DIR"

# ── Function: Build image ──────────────────────────────────────────────
build_image() {
  echo -e "${BLUE}[*] Building devcontainer image: $IMAGE_NAME${NC}"
  docker build -t "$IMAGE_NAME" "$SCRIPT_DIR" || {
    echo -e "${RED}[!] Build failed${NC}"
    exit 1
  }
  echo -e "${GREEN}[✓] Image built successfully${NC}\n"
}

# ── Function: Run Docker Scout scan ────────────────────────────────────
scan_docker_scout() {
  echo -e "${BLUE}[*] Running Docker Scout CVE scan...${NC}"
  
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}[!] Docker not found${NC}"
    return 1
  fi
  
  SCOUT_REPORT="$REPORT_DIR/scout-report.json"
  SCOUT_SUMMARY="$REPORT_DIR/scout-summary.txt"
  
  # JSON report for CI/CD
  docker scout cves "$IMAGE_NAME" --format json > "$SCOUT_REPORT" 2>&1 || {
    echo -e "${RED}[!] Docker Scout scan failed${NC}"
    return 1
  }
  
  # Human-readable summary
  docker scout cves "$IMAGE_NAME" --summary > "$SCOUT_SUMMARY" 2>&1
  
  # Extract vulnerability counts
  CRITICAL=$(jq '[.vulnerabilities[]? | select(.severity == "critical")] | length' "$SCOUT_REPORT" 2>/dev/null || echo "0")
  HIGH=$(jq '[.vulnerabilities[]? | select(.severity == "high")] | length' "$SCOUT_REPORT" 2>/dev/null || echo "0")
  MEDIUM=$(jq '[.vulnerabilities[]? | select(.severity == "medium")] | length' "$SCOUT_REPORT" 2>/dev/null || echo "0")
  LOW=$(jq '[.vulnerabilities[]? | select(.severity == "low")] | length' "$SCOUT_REPORT" 2>/dev/null || echo "0")
  
  echo -e "${YELLOW}[*] Docker Scout Results:${NC}"
  echo -e "  Critical: ${RED}$CRITICAL${NC}"
  echo -e "  High:     ${YELLOW}$HIGH${NC}"
  echo -e "  Medium:   $MEDIUM"
  echo -e "  Low:      ${GREEN}$LOW${NC}"
  echo -e "  Report:   $SCOUT_REPORT\n"
  
  # Fail if HIGH/CRITICAL found
  if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
    echo -e "${RED}[!] Found $CRITICAL CRITICAL and $HIGH HIGH severity vulnerabilities${NC}"
    return 1
  fi
  
  echo -e "${GREEN}[✓] Docker Scout scan passed${NC}\n"
  return 0
}

# ── Function: Run Trivy scan ───────────────────────────────────────────
scan_trivy() {
  echo -e "${BLUE}[*] Running Trivy CVE scan...${NC}"
  
  if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}[!] Trivy not found. Install from: https://github.com/aquasecurity/trivy${NC}"
    return 1
  fi
  
  TRIVY_REPORT="$REPORT_DIR/trivy-report.json"
  TRIVY_SUMMARY="$REPORT_DIR/trivy-summary.txt"
  
  # JSON report
  trivy image "$IMAGE_NAME" --format json --severity CRITICAL,HIGH > "$TRIVY_REPORT" 2>&1 || {
    echo -e "${RED}[!] Trivy scan failed${NC}"
    return 1
  }
  
  # Summary
  trivy image "$IMAGE_NAME" --severity CRITICAL,HIGH > "$TRIVY_SUMMARY" 2>&1
  
  # Extract counts
  CRITICAL=$(jq '[.Results[]?.Misconfigurations[]? | select(.Severity == "CRITICAL")] | length' "$TRIVY_REPORT" 2>/dev/null || echo "0")
  HIGH=$(jq '[.Results[]?.Misconfigurations[]? | select(.Severity == "HIGH")] | length' "$TRIVY_REPORT" 2>/dev/null || echo "0")
  
  echo -e "${YELLOW}[*] Trivy Results:${NC}"
  echo -e "  Critical: ${RED}$CRITICAL${NC}"
  echo -e "  High:     ${YELLOW}$HIGH${NC}"
  echo -e "  Report:   $TRIVY_REPORT\n"
  
  if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
    echo -e "${RED}[!] Found vulnerabilities${NC}"
    return 1
  fi
  
  echo -e "${GREEN}[✓] Trivy scan passed${NC}\n"
  return 0
}

# ── Main ───────────────────────────────────────────────────────────────
main() {
  local scan_type="scout"
  
  if [[ $# -gt 0 ]]; then
    case "$1" in
      --trivy) scan_type="trivy" ;;
      --full)  scan_type="full" ;;
      *)       echo "Usage: $0 [--scout|--trivy|--full]"; exit 1 ;;
    esac
  fi
  
  echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  DevContainer Security CVE Scan                           ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}\n"
  
  build_image
  
  SCOUT_PASS=true
  TRIVY_PASS=true
  
  if [[ "$scan_type" == "scout" || "$scan_type" == "full" ]]; then
    scan_docker_scout || SCOUT_PASS=false
  fi
  
  if [[ "$scan_type" == "trivy" || "$scan_type" == "full" ]]; then
    scan_trivy || TRIVY_PASS=false
  fi
  
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  
  if [[ "$SCOUT_PASS" == false || "$TRIVY_PASS" == false ]]; then
    echo -e "${RED}[✗] Security scan FAILED${NC}"
    echo -e "    Reports saved to: $REPORT_DIR"
    exit 1
  fi
  
  echo -e "${GREEN}[✓] All security scans PASSED${NC}"
  echo -e "    Reports saved to: $REPORT_DIR"
  exit 0
}

main "$@"
