#!/usr/bin/env bash
# ==============================================================================
# Script: simulate-log-incidents.sh
# Description: Generates realistic e-commerce incidents to test ELK logging & Kibana
# Usage: ./simulate-log-incidents.sh [mongo|mysql|payment|all]
# ==============================================================================
set -euo pipefail

TARGET="${1:-all}"

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
log_warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
log_success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }

simulate_mongo_fault() {
    log_warn "1. Simulating MongoDB Failure: Scaling MongoDB to 0 replicas..."
    kubectl scale deployment/mongodb -n robot-shop --replicas=0
    log_info "Triggering catalogue requests to force MongoDB connection timeout errors..."
    WEB_POD=$(kubectl get pod -n robot-shop -l app=web -o jsonpath="{.items[0].metadata.name}" 2>/dev/null || true)
    if [[ -n "${WEB_POD}" ]]; then
        kubectl exec -n robot-shop "${WEB_POD}" -- curl -s http://catalogue:8080/products || true
    fi
    sleep 5
    log_info "Restoring MongoDB replicas to 1..."
    kubectl scale deployment/mongodb -n robot-shop --replicas=1
}

simulate_payment_fault() {
    log_warn "2. Simulating Payment Service Errors (Invalid Payload & 500s)..."
    WEB_POD=$(kubectl get pod -n robot-shop -l app=web -o jsonpath="{.items[0].metadata.name}" 2>/dev/null || true)
    if [[ -n "${WEB_POD}" ]]; then
        kubectl exec -n robot-shop "${WEB_POD}" -- curl -s -X POST http://payment:8080/pay/order-invalid-999 \
            -H "Content-Type: application/json" \
            -d '{"amount": -500, "currency": "INVALID", "token": "expired"}' || true
    fi
}

simulate_mysql_fault() {
    log_warn "3. Simulating MySQL Connection Saturation / Deadlock warnings..."
    SHIPPING_POD=$(kubectl get pod -n robot-shop -l app=shipping -o jsonpath="{.items[0].metadata.name}" 2>/dev/null || true)
    if [[ -n "${SHIPPING_POD}" ]]; then
        kubectl exec -n robot-shop "${SHIPPING_POD}" -- curl -s http://shipping:8080/cities/9999999 || true
    fi
}

case "${TARGET}" in
    mongo)
        simulate_mongo_fault
        ;;
    payment)
        simulate_payment_fault
        ;;
    mysql)
        simulate_mysql_fault
        ;;
    all)
        simulate_mongo_fault
        simulate_payment_fault
        simulate_mysql_fault
        ;;
    *)
        echo "Unknown target: ${TARGET}. Options: mongo, payment, mysql, all"
        exit 1
        ;;
esac

log_success "Fault simulation complete!"
log_info "Open Kibana (port 5601) and run query: kubernetes.namespace_name: \"robot-shop\" AND (level: \"error\" OR log: \"*Error*\" OR log: \"*timeout*\")"
