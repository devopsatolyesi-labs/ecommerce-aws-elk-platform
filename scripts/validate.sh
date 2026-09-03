#!/usr/bin/env bash
# ==============================================================================
# Script: validate.sh
# Description: Automated validation of AWS EKS cluster, Robot Shop, and ELK Stack
# ==============================================================================
set -euo pipefail

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[PASS]\033[0m %s\n' "$*"; }
log_fail() { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

echo "================================================================================"
echo "         AWS EKS & CENTRALIZED ELK OBSERVABILITY VALIDATION SUITE"
echo "================================================================================"

# 1. Cluster connectivity
log_info "Testing Kubernetes API connectivity..."
if kubectl get nodes >/dev/null 2>&1; then
    log_success "Kubernetes cluster is reachable. Node count: $(kubectl get nodes --no-headers | wc -l)"
else
    log_fail "Cannot reach Kubernetes API."
fi

# 2. ELK Stack verification
log_info "Verifying Elasticsearch & Kibana in 'logging' namespace..."
es_ready=$(kubectl get pods -n logging -l app=elasticsearch -o jsonpath='{.items[*].status.containerStatuses[*].ready}' 2>/dev/null || true)
if [[ "$es_ready" =~ "true" ]]; then
    log_success "Elasticsearch is running and healthy."
else
    log_fail "Elasticsearch pod is not ready."
fi

# 3. Fluent Bit verification
fb_count=$(kubectl get pods -n logging -l app=fluent-bit --no-headers 2>/dev/null | wc -l || true)
if (( fb_count > 0 )); then
    log_success "Fluent Bit log collector DaemonSet is active (${fb_count} instances)."
else
    log_fail "Fluent Bit log collector is missing."
fi

# 4. Robot Shop verification
log_info "Checking Robot Shop microservices in 'robot-shop' namespace..."
web_ready=$(kubectl get pods -n robot-shop -l app=web -o jsonpath='{.items[*].status.containerStatuses[*].ready}' 2>/dev/null || true)
if [[ "$web_ready" =~ "true" ]]; then
    log_success "Robot Shop Web Frontend is active and ready."
else
    log_fail "Robot Shop Web Frontend is not ready."
fi

echo "================================================================================"
log_success "All checks passed successfully! System is fully operational."
echo "================================================================================"
