#!/usr/bin/env bash
# ==============================================================================
# Script: deploy-aws-infra.sh
# Description: Modular Multi-Environment AWS EKS Platform Provisioner
# Usage: ./deploy-aws-infra.sh [dev|staging|prod]
# ==============================================================================
set -euo pipefail

ENV="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"
TFVARS_FILE="${TERRAFORM_DIR}/environments/${ENV}.tfvars"

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }
log_error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

if ! command -v terraform >/dev/null 2>&1; then
    log_error "'terraform' CLI is required. Please install Terraform."
    exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
    log_error "'aws' CLI is required. Please configure AWS CLI credentials."
    exit 1
fi

if [[ ! -f "${TFVARS_FILE}" ]]; then
    log_error "Environment file not found: ${TFVARS_FILE}"
    exit 1
fi

log_info "Verifying AWS credentials..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="${AWS_REGION:-$(aws configure get region || echo "us-east-1")}"
AWS_REGION="${AWS_REGION:-us-east-1}"
log_info "Connected to AWS Account: ${ACCOUNT_ID} (Region: ${AWS_REGION}, Target Env: ${ENV})"

# Setup S3 State Bucket (Pure S3, No DynamoDB needed)
BUCKET_NAME="${S3_BUCKET_NAME:-robotshop-tfstate-${ACCOUNT_ID}-${ENV}}"
log_info "Ensuring S3 state bucket exists: ${BUCKET_NAME}..."
if ! aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    log_info "Creating S3 bucket ${BUCKET_NAME} in ${AWS_REGION}..."
    if [ "${AWS_REGION}" = "us-east-1" ]; then
        aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${AWS_REGION}"
    else
        aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${AWS_REGION}" \
            --create-bucket-configuration LocationConstraint="${AWS_REGION}"
    fi
    aws s3api put-bucket-versioning --bucket "${BUCKET_NAME}" --versioning-configuration Status=Enabled
    aws s3api put-bucket-encryption --bucket "${BUCKET_NAME}" \
        --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
fi

cd "${TERRAFORM_DIR}"
log_info "Initializing Terraform with S3 backend..."
terraform init \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="key=environments/${ENV}/terraform.tfstate" \
    -backend-config="region=${AWS_REGION}"

log_info "Applying Terraform Plan for environment: ${ENV}..."
terraform apply -auto-approve -var-file="${TFVARS_FILE}"

log_success "AWS EKS Cluster provisioned successfully!"
CLUSTER_NAME=$(terraform output -raw cluster_name)
aws eks --region "${AWS_REGION}" update-kubeconfig --name "${CLUSTER_NAME}"
log_info "Kubectl configured. Verifying worker nodes:"
kubectl get nodes -o wide
