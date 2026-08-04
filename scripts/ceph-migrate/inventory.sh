#!/usr/bin/env bash
set -euo pipefail

kubectl get pv -o json | jq -r '
  .items[]
  | select(.spec.csi.driver | startswith("rook-ceph."))
  | [.spec.claimRef.namespace, .spec.claimRef.name, .spec.storageClassName, .spec.capacity.storage] | @tsv
' | sort | column -t
