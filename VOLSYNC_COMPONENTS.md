# Volsync Storage Components

## Overview

This directory contains reusable Kustomize components for creating PVCs with automatic Volsync backups.

## Component: `volsync-pvc.yaml`

A unified component that creates both a PersistentVolumeClaim and a Volsync ReplicationSource.

### What it creates:

1. **PersistentVolumeClaim** - The storage volume for your app
2. **ReplicationSource** - Automatic backup to GCS using Restic

### Usage

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../../../components/storage/volsync-pvc.yaml

configMapGenerator:
  - name: volsync-<app>-config
    literals:
      - name=<pvc-name>
      - namespace=<k8s-namespace>
      - size=50Gi
      - schedule=0 2 * * *
      # ... other options
```

### Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | - | PVC name (required) |
| `namespace` | - | Kubernetes namespace (required) |
| `size` | `100Gi` | PVC capacity |
| `accessMode` | `ReadWriteOnce` | Access mode (RWO, RWX, ROX) |
| `storageClass` | `standard` | Storage class name |
| `schedule` | `0 1 * * *` | Cron schedule for backups |
| `retainHourly` | `24` | Hourly backup retention |
| `retainDaily` | `7` | Daily backup retention |
| `retainWeekly` | `4` | Weekly backup retention |
| `retainMonthly` | `12` | Monthly backup retention |
| `cacheSize` | `20Gi` | Cache PVC size for Restic operations |

## Examples

### Plex Media Server

```yaml
# kubernetes/apps/volsync/storage/plex/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../../../components/storage/volsync-pvc.yaml

configMapGenerator:
  - name: volsync-plex-config
    literals:
      - name=plex-config
      - namespace=default
      - size=50Gi
      - accessMode=ReadWriteOnce
      - storageClass=standard
      - schedule=0 2 * * *
      - retainHourly=24
      - retainDaily=7
      - retainWeekly=4
      - retainMonthly=12
      - cacheSize=20Gi

generatorOptions:
  disableNameSuffixHash: true
```

### Jellyfin Media Server

```yaml
# kubernetes/apps/volsync/storage/jellyfin/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../../../components/storage/volsync-pvc.yaml

configMapGenerator:
  - name: volsync-jellyfin-config
    literals:
      - name=jellyfin-data
      - namespace=default
      - size=100Gi
      - accessMode=ReadWriteOnce
      - storageClass=standard
      - schedule=0 3 * * *
      - cacheSize=25Gi

generatorOptions:
  disableNameSuffixHash: true
```

### Sonarr/Radarr

```yaml
# kubernetes/apps/volsync/storage/sonarr/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../../../components/storage/volsync-pvc.yaml

configMapGenerator:
  - name: volsync-sonarr-config
    literals:
      - name=sonarr-config
      - namespace=default
      - size=20Gi
      - accessMode=ReadWriteOnce
      - storageClass=standard
      - schedule=0 4 * * *
      - cacheSize=10Gi

generatorOptions:
  disableNameSuffixHash: true
```

## Adding to Flux

Update your volsync app Kustomization to include the storage components:

```yaml
# kubernetes/apps/volsync/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - gcs-bucket.yaml
  - gcs-credentials.yaml
  - onepassword-gcs.yaml
  - gcs-destination/kustomization.yaml
  - storage/plex
  - storage/jellyfin
  - storage/sonarr
  - storage/radarr
```

## Backup Schedule Best Practices

Stagger your backup schedules to avoid overwhelming your GCS bucket:

- **Plex**: `0 2 * * *` (2 AM)
- **Jellyfin**: `0 3 * * *` (3 AM)
- **Sonarr**: `0 4 * * *` (4 AM)
- **Radarr**: `0 5 * * *` (5 AM)
- **Readarr**: `0 6 * * *` (6 AM)

## Monitoring

Check backup status:

```bash
kubectl get replicationsource -A
kubectl get pvc -A -l app.kubernetes.io/part-of=volsync-storage
```

Watch backup progress:

```bash
kubectl get replicationsource -A -w
```

## Restoring a Backup

To restore from a backup:

1. Create a new PVC with the same name
2. Create a ReplicationDestination pointing to the backup
3. Volsync will restore the data

See the [Volsync Documentation](https://volsync.readthedocs.io/) for detailed restore procedures.
