#!/usr/bin/env bash
# ==============================================================================
# Script: deploy-aws-infra.sh
# Description: Automated AWS VPC, EKS Cluster & ECS Fargate Provisioner via Terraform
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }
log_error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

if ! command -v terraform >/dev/null 2>&1; then
    log_error "'terraform' CLI is required. Please install Terraform."
    exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
    log_error "'aws' CLI is required. Please install and configure AWS CLI credentials."
    exit 1
fi

log_info "Verifying AWS credentials..."
aws sts get-caller-identity >/dev/null

log_info "Initializing Terraform in ${TERRAFORM_DIR}..."
cd "${TERRAFORM_DIR}"
terraform init

log_info "Executing Terraform Apply (Zero manual steps)..."
terraform apply -auto-approve

log_success "AWS Infrastructure successfully provisioned!"
eval "$(terraform output -raw kubeconfig_command)"
log_info "Updated kubeconfig. Verifying cluster nodes..."
kubectl get nodes
