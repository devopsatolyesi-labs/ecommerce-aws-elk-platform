#!/usr/bin/env bash
# ==============================================================================
# Script: deploy-elk.sh
# Description: Deploys Elasticsearch, Kibana, and Fluent Bit on Kubernetes
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }

log_info "Deploying Elasticsearch, Kibana, and Fluent Bit..."
kubectl apply -f "${ROOT_DIR}/elk-stack/01-elasticsearch.yaml"
kubectl apply -f "${ROOT_DIR}/elk-stack/02-kibana.yaml"
kubectl apply -f "${ROOT_DIR}/elk-stack/03-fluent-bit.yaml"

log_info "Waiting for Elasticsearch readiness..."
kubectl rollout status statefulset/elasticsearch -n logging --timeout=180s

log_info "Waiting for Kibana readiness..."
kubectl rollout status deployment/kibana -n logging --timeout=180s

log_success "Centralized ELK Stack successfully deployed and active in 'logging' namespace!"
kubectl get pods,svc -n logging
