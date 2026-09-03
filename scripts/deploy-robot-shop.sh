#!/usr/bin/env bash
# ==============================================================================
# Script: deploy-robot-shop.sh
# Description: Deploys Instana Robot Shop multi-tier microservices on Kubernetes
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }

log_info "Creating 'robot-shop' namespace..."
kubectl create namespace robot-shop --dry-run=client -o yaml | kubectl apply -f -

log_info "Deploying Robot Shop microservices and databases..."
kubectl apply -f "${ROOT_DIR}/K8s/descriptors/" -n robot-shop

log_info "Waiting for web and core services rollout..."
kubectl rollout status deployment/web -n robot-shop --timeout=120s
kubectl rollout status deployment/catalogue -n robot-shop --timeout=120s
kubectl rollout status deployment/cart -n robot-shop --timeout=120s

log_success "Robot Shop microservices successfully deployed!"
kubectl get pods,svc -n robot-shop
