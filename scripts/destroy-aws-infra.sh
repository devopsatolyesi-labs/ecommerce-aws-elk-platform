#!/usr/bin/env bash
# ==============================================================================
# Script: destroy-aws-infra.sh
# Description: Automated teardown of AWS resources to prevent cloud costs
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }

log_info "Destroying AWS resources in ${TERRAFORM_DIR} (Zero manual steps)..."
cd "${TERRAFORM_DIR}"
terraform destroy -auto-approve

log_success "All AWS cloud resources have been completely decommissioned. Zero lingering costs."
