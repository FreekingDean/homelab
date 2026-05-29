#!/bin/bash
# Volsync Verification Script
# Run this after deployment to verify everything is working

set -e

echo "🔍 Volsync Verification Script"
echo "==============================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1"
        return 1
    fi
}

# Function to check resources
check_resource() {
    local resource=$1
    local namespace=$2
    local name=$3
    
    if kubectl get "$resource" -n "$namespace" "$name" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $resource/$name in $namespace"
        return 0
    else
        echo -e "${RED}✗${NC} $resource/$name in $namespace not found"
        return 1
    fi
}

echo "📦 Checking Volsync Operator"
echo "----------------------------"
kubectl get pods -n volsync -l app=volsync &> /dev/null
check_status "Volsync pods running"

kubectl get deployment -n volsync volsync &> /dev/null
check_status "Volsync deployment exists"

echo ""
echo "🔐 Checking ExternalSecrets"
echo "---------------------------"
check_resource "externalsecret" "volsync" "volsync-gcp-credentials"

kubectl get secret -n volsync volsync-gcp-credentials &> /dev/null
check_status "GCP credentials secret exists"

echo ""
echo "🎯 Checking Replication Destinations"
echo "-------------------------------------"
check_resource "replicationdestination" "volsync" "volsync-gcs-destination"

echo ""
echo "📁 Checking Replication Sources"
echo "--------------------------------"
check_resource "replicationsource" "default" "plex-backup"

echo ""
echo "📊 Checking Backup Status"
echo "-------------------------"
kubectl get replicationsource -A -o wide 2>/dev/null || echo -e "${YELLOW}⚠ No replication sources found${NC}"

echo ""
echo "🔍 Checking Flux Kustomizations"
echo "--------------------------------"
kubectl get kustomization -n flux-system | grep volsync || echo -e "${YELLOW}⚠ No Volsync Kustomizations found${NC}"

echo ""
echo "📝 Checking Volsync Logs"
echo "------------------------"
volsync_pod=$(kubectl get pods -n volsync -l app=volsync -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$volsync_pod" ]; then
    echo "Last 10 lines of Volsync logs:"
    kubectl logs -n volsync "$volsync_pod" --tail=10
else
    echo -e "${YELLOW}⚠ No Volsync pod found to check logs${NC}"
fi

echo ""
echo "🔗 Testing GCS Connectivity"
echo "---------------------------"
if [ ! -z "$volsync_pod" ]; then
    echo "Testing Restic repository..."
    kubectl -n volsync exec "$volsync_pod" -- \
        restic -r gs://your-project-id-backups/volsync \
        --password-file=/etc/restic-credentials/RESTIC_PASSWORD \
        stats 2>&1 | head -20 || echo -e "${YELLOW}⚠ Could not test GCS connectivity${NC}"
fi

echo ""
echo "✅ Verification Complete"
echo "========================"
echo ""
echo "If you see any ✗ marks above, check the following:"
echo "  1. Terraform applied successfully (gcs.tf)"
echo "  2. Service account key stored in 1Password (volsync-gcp-credentials)"
echo "  3. ExternalSecret is syncing properly"
echo "  4. PVC names are correct in backup configs"
echo ""
echo "To fix issues:"
echo "  - Check Flux logs: kubectl logs -n flux-system -l app=flux"
echo "  - Check ExternalSecret: kubectl describe externalsecret -n volsync volsync-gcp-credentials"
echo "  - Check Volsync: kubectl logs -n volsync -l app=volsync -f"
