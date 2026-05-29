# Volsync Backup Setup Guide

This guide walks you through setting up Volsync with GCS backups using Terraform and 1Password integration.

## Prerequisites

- Terraform CLI installed
- GCP account with billing enabled
- 1Password Connect running (you already have this at `https://onepassword-connect.deangalvin.dev`)
- kubectl configured for your cluster

## Step 1: Create GCS Bucket and Service Account

Run Terraform to create the GCS infrastructure:

```bash
cd /home/node/.openclaw/workspace/homelab/terraform

# Initialize Terraform
terraform init

# Set your GCP project ID (edit variables.tf or use TF_VAR)
export TF_VAR_gcp_project_id="your-gcp-project-id"

# Preview changes
terraform plan

# Apply changes
terraform apply
```

This will create:
- A GCS bucket: `your-project-id-backups`
- A service account: `volsync-backup@your-project-id.iam.gserviceaccount.com`
- IAM policies to grant the service account access to the bucket

## Step 2: Create Service Account Key

```bash
# Create the service account key
gcloud iam service-accounts keys create volsync-key.json \
  --iam-account=volsync-backup@your-gcp-project-id.iam.gserviceaccount.com

# Verify the key
cat volsync-key.json
```

## Step 3: Store Credentials in 1Password

1. Open your 1Password Connect vault: **Homelab**
2. Create a new **Password** item named: `volsync-gcp-credentials`
3. Add a **Text** field with the name: `service-account.json`
4. Paste the contents of `volsync-key.json` into this field
5. Save the item

The item path should be: `volsync-gcp-credentials`

## Step 4: Deploy Kubernetes Resources

```bash
# From the homelab root directory
cd /home/node/.openclaw/workspace/homelab

# Add and commit the new files
git add .
git commit -m "feat(volsync): add GCS backup configuration with 1Password"

# Push to trigger Flux
git push
```

Flux will automatically deploy the resources.

## Step 5: Verify Installation

```bash
# Check if Volsync is running
kubectl get pods -n volsync

# Check ExternalSecret status
kubectl get externalsecret -n volsync volsync-gcp-credentials

# Check if credentials were created
kubectl get secret -n volsync volsync-gcp-credentials -o yaml
```

## Step 6: Configure Backup Sources

Now you need to add backup sources for your apps. Here's an example for Plex:

### Create the backup source:

```bash
# Create directory for Plex backup source
mkdir -p kubernetes/apps/volsync/apps/plex

# Create the ReplicationSource manifest
cat > kubernetes/apps/volsync/apps/plex/replicationsource.yaml << 'EOF'
---
apiVersion: volsync.backube/v1alpha1
kind: ReplicationSource
metadata:
  name: plex-backup
  namespace: default  # Update: match your Plex namespace
spec:
  sourcePVC: config-plex-0  # Update: match your Plex PVC name
  trigger:
    schedule: "0 2 * * *"  # Daily at 2 AM UTC
  restic:
    copyMethod: Snapshot
    repository: volsync-gcp-credentials
    capacity: 100Gi
    retain:
      hourly: 24   # Keep 24 hourly backups
      daily: 7     # Keep 7 daily backups
      weekly: 4    # Keep 4 weekly backups
      monthly: 12  # Keep 12 monthly backups
    cacheStorageClass: ceph-rbd  # Update: match your fast storage class
    cacheCapacity: 20Gi
EOF
```

### Add to Flux:

```bash
# Create a Kustomization for this app
cat > kubernetes/apps/volsync/apps/plex/kustomization.yaml << 'EOF'
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ./replicationsource.yaml
EOF
```

## Step 7: Monitor Backups

```bash
# Watch backup status
kubectl get replicationsource -A -w

# Check Restic repository
kubectl -n volsync exec -it $(kubectl get pods -n volsync -l app=volsync -o jsonpath='{.items[0].metadata.name}') -- restic -r gs://your-project-id-backups/volsync ls

# View backup logs
kubectl logs -n volsync -l app=volsync -f
```

## App-Specific PVC Names

Here are common PVC names for your media apps:

| App | Typical PVC Name | Namespace |
|-----|------------------|-----------|
| Plex | `config-plex-0` or `plex-data` | default |
| Jellyfin | `jellyfin-data` | default |
| Sonarr | `sonarr-config` or `sonarr-data` | default |
| Radarr | `radarr-config` or `radarr-data` | default |
| Readarr | `readarr-data` | default |
| Lidarr | `lidarr-data` | default |
| Prowlarr | `prowlarr-data` | default |
| Sabnzbd | `sabnzbd-data` | default |

**To find your actual PVC names:**

```bash
kubectl get pvc -A | grep -E "(plex|jellyfin|sonarr|radarr)"
```

## Restoring a Backup

### Option 1: Using Volsync UI (if configured)

### Option 2: Manual restore with Restic

```bash
# Create a temporary PVC
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: plex-restore-temp
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: ceph-rbd
EOF

# Restore from backup
kubectl -n volsync exec -it $(kubectl get pods -n volsync -l app=volsync -o jsonpath='{.items[0].metadata.name}') -- \
  restic -r gs://your-project-id-backups/volsync \
  --password-file=/etc/restic-credentials/RESTIC_PASSWORD \
  restore latest \
  --target=/restore \
  --pod-name=restore-pod \
  --namespace=default
```

## Troubleshooting

### ExternalSecret not syncing

```bash
# Check ExternalSecret status
kubectl describe externalsecret -n volsync volsync-gcp-credentials

# Check 1Password Connect
kubectl logs -n kube-system -l app=onepassword-connect
```

### Volsync pod not running

```bash
# Check Volsync logs
kubectl logs -n volsync -l app=volsync -f

# Check for errors
kubectl describe pod -n volsync -l app=volsync
```

### Restic repository errors

```bash
# Test repository connectivity
kubectl -n volsync exec -it $(kubectl get pods -n volsync -l app=volsync -o jsonpath='{.items[0].metadata.name}') -- \
  restic -r gs://your-project-id-backups/volsync \
  --password-file=/etc/restic-credentials/RESTIC_PASSWORD \
  stats

# Check repository exists
gsutil ls gs://your-project-id-backups/
```

## Next Steps

1. **Add backup sources** for all your media apps
2. **Set up alerts** for backup failures (see monitoring/alerting setup)
3. **Test restores** regularly to ensure backups work
4. **Configure retention policies** based on your needs
5. **Add monitoring dashboards** for backup status

## Resources

- [Volsync Documentation](https://volsync.readthedocs.io/)
- [Restic Documentation](https://restic.readthedocs.io/)
- [GCS Backend for Restic](https://restic.readthedocs.io/en/latest/070_restic_on_cloud_storage.html)
