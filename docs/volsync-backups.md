# Volsync GCS Backups

Per-app PVCs are backed up to Google Cloud Storage with [Volsync](https://volsync.readthedocs.io/)
and restic. Backups are opt-in per app via the reusable
`kubernetes/components/volsync` Kustomize component.

## Infrastructure

The GCS bucket and the backup service account are provisioned by Terraform
in [`terraform/gcs.tf`](../terraform/gcs.tf):

```bash
cd terraform
export TF_VAR_gcp_project_id="<your-gcp-project-id>"
terraform init
terraform apply
```

Outputs: `bucket_name` and `service_account_email`.

## Credentials

The `components/volsync` ExternalSecret reads a single `restic` item from the
`onepassword-connect` ClusterSecretStore and renders the restic repository
secret for each app. Store these fields on the 1Password `restic` item:

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| `repository_template`| `s3:https://storage.googleapis.com/<bucket_name>`  |
| `restic_password`    | a strong restic repository password                |
| `gcp_access_key`     | HMAC access key for the backup service account     |
| `gcp_access_secret`  | HMAC secret for the backup service account         |

The repository for an app becomes `${repository_template}/${PVC_NAME}`.

## Enabling backups for an app

Reference the component from the app's Flux Kustomization and pass the PVC
name to back up (see `kubernetes/apps/default/plex/ks.yaml` for a live
example):

```yaml
spec:
  dependsOn:
    - name: cluster-apps-volsync
  components:
    - ../../../../components/volsync
  postBuild:
    substitute:
      PVC_NAME: config-plex-0
```

The PVC itself lives alongside the app (e.g. `plex/app/pvc.yaml`).

## Operations

Tasks live in `.taskfiles/VolSync/Tasks.yml`:

```bash
task vs:verify                      # check operator + backup resources
task vs:snapshot rsrc=config-plex-0 # trigger a backup
task vs:list     rsrc=config-plex-0 # list snapshots
task vs:restore  rsrc=config-plex-0 # restore from the latest snapshot
```
