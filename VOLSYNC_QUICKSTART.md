# Volsync Quick Start Guide

## What You Need to Do

### 1. Create GCS Infrastructure with Terraform

```bash
cd /home/node/.openclaw/workspace/homelab/terraform

# Initialize
terraform init

# Set your GCP project ID
export TF_VAR_gcp_project_id="your-gcp-project-id"

# Preview
terraform plan

# Apply
terraform apply
```

**Outputs you'll get:**
- `bucket_name`: e.g., `your-project-id-backups`
- `service_account_email`: e.g., `volsync-backup@your-project-id.iam.gserviceaccount.com`

### 2. Create Service Account Key

```bash
gcloud iam service-accounts keys create volsync-key.json \
  --iam-account=volsync-backup@your-project-id.iam.gserviceaccount.com
```

### 3. Store in 1Password

1. Open 1Password Connect vault: **Homelab**
2. Create new **Password** item: `volsync-gcp-credentials`
3. Add **Text** field: `service-account.json`
4. Paste contents of `volsync-key.json`
5. Save

### 4. Update Plex PVC Name

Edit `kubernetes/apps/volsync/plex-backup.yaml`:

```yaml
spec:
  sourcePVC: config-plex-0  # UPDATE THIS to match your actual PVC
  namespace: default        # UPDATE THIS to match your Plex namespace
```

**To find your Plex PVC:**
```bash
kubectl get pvc -A | grep -i plex
```

### 5. Commit and Push

```bash
cd /home/node/.openclaw/workspace/homelab

git add .
git commit -m "feat(volsync): add GCS backup setup with 1Password"
git push
```

### 6. Verify Deployment

```bash
# Check Volsync operator
kubectl get pods -n volsync

# Check ExternalSecret
kubectl get externalsecret -n volsync volsync-gcp-credentials

# Check if credentials were created
kubectl get secret -n volsync volsync-gcp-credentials -o yaml

# Watch for backup to run
kubectl get replicationsource -A -w
```

### 7. Monitor Backups

```bash
# Check backup status
kubectl get replicationsource -A

# View Volsync logs
kubectl logs -n volsync -l app=volsync -f

# Check Restic repository
kubectl -n volsync exec -it $(kubectl get pods -n volsync -l app=volsync -o jsonpath='{.items[0].metadata.name}') -- \
  restic -r gs://your-project-id-backups/volsync \
  --password-file=/etc/restic-credentials/RESTIC_PASSWORD \
  ls
```

## Adding More Apps

To add backups for other apps (Sonarr, Radarr, Jellyfin, etc.), create similar files:

### Example: Sonarr Backup

```bash
cat > kubernetes/apps/volsync/sonarr-backup.yaml << 'EOF'
---
apiVersion: volsync.backube/v1alpha1
kind: ReplicationSource
metadata:
  name: sonarr-backup
  namespace: default  # UPDATE to your Sonarr namespace
spec:
  sourcePVC: sonarr-config  # UPDATE to your Sonarr PVC name
  trigger:
    schedule: "0 1 * * *"  # Daily at 1 AM UTC
  restic:
    copyMethod: Snapshot
    repository: volsync-gcp-credentials
    capacity: 50Gi
    retain:
      hourly: 24
      daily: 7
      weekly: 4
      monthly: 12
    cacheStorageClass: ceph-rbd
    cacheCapacity: 20Gi
EOF
```

Then add it to the kustomization:

```yaml
# In kubernetes/apps/volsync/kustomization.yaml
resources:
  - ./sonarr-backup.yaml
```

## Common PVC Names

| App | Typical PVC Name |
|-----|------------------|
| Plex | `config-plex-0` or `plex-data` |
| Jellyfin | `jellyfin-data` |
| Sonarr | `sonarr-config` or `sonarr-data` |
| Radarr | `radarr-config` or `radarr-data` |
| Readarr | `readarr-data` |
| Lidarr | `lidarr-data` |
| Prowlarr | `prowlarr-data` |
| Sabnzbd | `sabnzbd-data` |

## Troubleshooting

### ExternalSecret not syncing

```bash
kubectl describe externalsecret -n volsync volsync-gcp-credentials
kubectl logs -n kube-system -l app=onepassword-connect
```

### Volsync pod not running

```bash
kubectl logs -n volsync -l app=volsync -f
kubectl describe pod -n volsync -l app=volsync
```

### Restic errors

```bash
# Test repository
kubectl -n volsync exec -it $(kubectl get pods -n volsync -l app=volsync -o jsonpath='{.items[0].metadata.name}') -- \
  restic -r gs://your-project-id-backups/volsync \
  --password-file=/etc/restic-credentials/RESTIC_PASSWORD \
  stats
```

## Next Steps

1. ✅ Add backup sources for all your media apps
2. ⏳ Set up alerting for backup failures
3. ⏳ Test restores regularly
4. ⏳ Configure retention policies
5. ⏳ Add monitoring dashboards

## Resources

- [Volsync Docs](https://volsync.readthedocs.io/)
- [Restic Docs](https://restic.readthedocs.io/)
- [GCS + Restic](https://restic.readthedocs.io/en/stable/070_restic_on_cloud_storage.html)
