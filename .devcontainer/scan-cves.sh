#!/usr/bin/env bash
# ============================================================================
# DevContainer Security Scan — Local CVE Scanning
# ============================================================================
# 
# Usage:
#   bash .devcontainer/scan-cves.sh          # Run Docker Scout
#   bash .devcontainer/scan-cves.sh --trivy  # Run Trivy instead
#   bash .devcontainer/scan-cves.sh --full   # Run both
#   bash .devcontainer/scan-cves.sh --current [--trivy|--full]
#                                        # Scan currently running container image
#
# Prerequisites:
#   - Docker Desktop with Docker Scout enabled
#   - OR Trivy installed locally (https://github.com/aquasecurity/trivy)
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="agentic-workshop:scan"
REPORT_DIR="${SCRIPT_DIR}/security-reports"
TARGET_IMAGE=""

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

mkdir -p "$REPORT_DIR"

has_docker_scout() {
  local output
  output="$(docker scout cves --help 2>&1 || true)"
  grep -qi "docker scout cves" <<< "$output"
}

# ── Function: Build image ──────────────────────────────────────────────
build_image() {
  echo -e "${BLUE}[*] Building devcontainer image: $IMAGE_NAME${NC}"
  docker build -t "$IMAGE_NAME" "$SCRIPT_DIR" || {
    echo -e "${RED}[!] Build failed${NC}"
    exit 1
  }
  echo -e "${GREEN}[✓] Image built successfully${NC}\n"
}

# ── Function: Resolve current container image ─────────────────────────
resolve_current_image() {
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}[!] Docker not found${NC}"
    return 1
  fi

  local container_id
  local image_ref

  container_id="$(hostname)"
  image_ref="$(docker inspect --format '{{.Image}}' "$container_id" 2>/dev/null || true)"

  if [[ -z "$image_ref" ]]; then
    echo -e "${RED}[!] Could not resolve current container image from Docker${NC}"
    return 1
  fi

  TARGET_IMAGE="$image_ref"
  echo -e "${GREEN}[✓] Using current container image: $TARGET_IMAGE${NC}\n"
  return 0
}

# ── Function: Run Docker Scout scan ────────────────────────────────────
scan_docker_scout() {
  echo -e "${BLUE}[*] Running Docker Scout CVE scan...${NC}"
  
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}[!] Docker not found${NC}"
    return 1
  fi

  if ! has_docker_scout; then
    echo -e "${YELLOW}[!] Docker Scout plugin not available (docker scout missing)${NC}"
    return 1
  fi
  
  SCOUT_REPORT="$REPORT_DIR/scout-report.json"
  SCOUT_SUMMARY="$REPORT_DIR/scout-summary.txt"

  # Human-readable output for local review.
  docker scout cves "$TARGET_IMAGE" > "$SCOUT_SUMMARY" 2>&1 || {
    echo -e "${RED}[!] Docker Scout scan output failed${NC}"
    return 1
  }

  # SPDX JSON report for archival/automation.
  docker scout cves "$TARGET_IMAGE" --format spdx > "$SCOUT_REPORT" 2>&1 || {
    echo -e "${RED}[!] Docker Scout report export failed${NC}"
    return 1
  }

  # Exit-code gate for high/critical vulnerabilities.
  if docker scout cves "$TARGET_IMAGE" --only-severity critical,high --exit-code > /dev/null 2>&1; then
    echo -e "${GREEN}[✓] Docker Scout scan passed (no HIGH/CRITICAL CVEs)${NC}"
    echo -e "  Summary:  $SCOUT_SUMMARY"
    echo -e "  Report:   $SCOUT_REPORT\n"
    return 0
  fi

  echo -e "${RED}[!] Docker Scout found HIGH/CRITICAL CVEs${NC}"
  echo -e "  Summary:  $SCOUT_SUMMARY"
  echo -e "  Report:   $SCOUT_REPORT\n"
  return 1
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
  trivy image "$TARGET_IMAGE" --format json --severity CRITICAL,HIGH > "$TRIVY_REPORT" 2>&1 || {
    echo -e "${RED}[!] Trivy scan failed${NC}"
    return 1
  }
  
  # Summary
  trivy image "$TARGET_IMAGE" --severity CRITICAL,HIGH > "$TRIVY_SUMMARY" 2>&1
  
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
  local target_mode="build"
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --scout)   scan_type="scout" ;;
      --trivy)   scan_type="trivy" ;;
      --full)    scan_type="full" ;;
      --current) target_mode="current" ;;
      *)
        echo "Usage: $0 [--scout|--trivy|--full] [--current]"
        exit 1
        ;;
    esac
    shift
  done
  
  echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  DevContainer Security CVE Scan                           ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}\n"
  
  # Build-based scanning only works when a Dockerfile exists.
  if [[ "$target_mode" == "current" ]]; then
    resolve_current_image || exit 1
  elif [[ -f "$SCRIPT_DIR/Dockerfile" ]]; then
    build_image
    TARGET_IMAGE="$IMAGE_NAME"
  else
    echo -e "${YELLOW}[!] No Dockerfile found in $SCRIPT_DIR; scanning current container image instead${NC}"
    resolve_current_image || exit 1
  fi

  if [[ "$scan_type" == "scout" ]]; then
    if ! has_docker_scout; then
      if command -v trivy > /dev/null 2>&1; then
        echo -e "${YELLOW}[!] Docker Scout unavailable; falling back to Trivy${NC}"
        scan_type="trivy"
      else
        echo -e "${RED}[!] No scanner available: install Docker Scout plugin or Trivy${NC}"
        echo -e "    Tip: run '$0 --trivy' after installing Trivy"
        exit 1
      fi
    fi
  fi
  
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
