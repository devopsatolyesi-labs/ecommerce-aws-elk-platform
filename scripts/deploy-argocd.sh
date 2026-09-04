#!/usr/bin/env bash
# ==============================================================================
# Script: deploy-argocd.sh
# Description: Installs Argo CD GitOps controller on EKS and configures LoadBalancer
# ==============================================================================
set -euo pipefail

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }

log_info "Creating 'argocd' namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

log_info "Installing official Argo CD manifests..."
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

log_info "Configuring Argo CD Server service as LoadBalancer..."
kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "LoadBalancer"}}' || true

log_info "Waiting for Argo CD Server deployment..."
kubectl -n argocd rollout status deployment/argocd-server --timeout=180s

log_info "Registering GitOps Applications (robot-shop and elk-stack)..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -f "${SCRIPT_DIR}/../argocd/"

log_success "Argo CD GitOps Controller successfully deployed!"
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "N/A")
echo "=========================================================="
echo "Argo CD Username: admin"
echo "Argo CD Initial Password: ${ARGOCD_PASS}"
echo "=========================================================="
