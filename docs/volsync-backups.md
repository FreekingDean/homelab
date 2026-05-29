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

restic reaches GCS over its S3-interoperable API, so it needs HMAC keys
rather than the service-account JSON. Terraform handles the whole chain:
`terraform/gcs.tf` creates an HMAC key for the backup service account, and
`terraform/onepassword.tf` writes the `restic` item into the `Homelab` vault
with the fields the `components/volsync` ExternalSecret extracts:

| Field                 | Source                                              |
| --------------------- | --------------------------------------------------- |
| `repository_template` | `s3:https://storage.googleapis.com/<bucket_name>`   |
| `restic_password`     | generated `random_password` (kept in TF state)      |
| `gcp_access_key`      | HMAC `access_id`                                    |
| `gcp_access_secret`   | HMAC `secret`                                       |

The repository for an app becomes `${repository_template}/${PVC_NAME}`.

Set `onepassword_connect_token` (a Connect token for the vault) as a
Terraform variable. If a `restic` item already exists in the vault, import
it before the first apply:

```bash
terraform import onepassword_item.restic <vault>/<item-uuid>
```

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
