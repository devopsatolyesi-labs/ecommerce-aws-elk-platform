#!/usr/bin/env bash
# ==============================================================================
# Script: deploy-robot-shop.sh
# Description: Deploys Instana Robot Shop microservices via Helm Chart
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }

if ! command -v helm >/dev/null 2>&1; then
    echo "[ERROR] 'helm' CLI is required. Please install Helm." >&2
    exit 1
fi

log_info "Deploying Robot Shop Helm Chart into 'robot-shop' namespace..."
helm upgrade --install robot-shop "${ROOT_DIR}/K8s/helm/" \
    --namespace robot-shop \
    --create-namespace \
    --wait --timeout 10m

log_info "Deploying automated traffic generator (Locust load-gen)..."
if [[ -f "${ROOT_DIR}/K8s/load-deployment.yaml" ]]; then
    kubectl apply -f "${ROOT_DIR}/K8s/load-deployment.yaml" -n robot-shop
fi

log_success "Robot Shop microservices successfully deployed and healthy!"
kubectl get pods,svc -n robot-shop
