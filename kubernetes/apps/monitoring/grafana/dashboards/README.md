# Grafana TV Dashboards

Optimized dashboards for 720p TV display with playlist rotation, managed via Grafana Operator.

## Overview

These dashboards are deployed using the Grafana Operator CRDs (`GrafanaDashboard`) which automatically:
- Create and manage dashboards in Grafana
- Handle updates when JSON files change
- Provide declarative dashboard management via GitOps

## Playlist

**URL (kiosk mode):**
```
https://grafana.deangalvin.dev/playlists/play/dff654pz8n8qoc?kiosk
```

**Rotation:** 45 seconds per dashboard

## Dashboards

### 1. Kubernetes Cluster (`01-kubernetes.json`)
- **UID:** `tv-kubernetes`
- **CRD:** `tv-kubernetes`
- Cluster node count and health (7 nodes)
- Pod statistics (running, failed, by phase)
- CPU and memory usage by node
- Time series graphs with legend tables

### 2. Storage & Ceph (`02-storage-ceph.json`)
- **UID:** `tv-storage`
- **CRD:** `tv-storage-ceph`
- Ceph cluster health and capacity (249 TB)
- Ceph I/O rates (read/write by pool)
- OSD status and counts
- Worker node disk usage (/var XFS mounts)

### 3. Network (`03-network.json`)
- **UID:** `tv-network`
- **CRD:** `tv-network`
- Total RX/TX in last 6h
- Current average RX/TX rates
- Per-node network traffic (ens19 physical interfaces)
- Packet rates (RX/TX)

### 4. Server Hardware (`04-servers.json`)
- **UID:** `tv-servers`
- **CRD:** `tv-servers`
- CPU temperatures (Challenger, Galaxy, Yamato via Redfish)
- System board exhaust temps
- Fan speeds (percentage)
- Power consumption

### 5. Home Status (`05-home.json`)
- **UID:** `tv-home`
- **CRD:** `tv-home`
- Indoor temperature (Fahrenheit gauge)
- Presence detection (Dean)
- Door locks (front, back, Volvo)
- Power consumption vs solar production
- Climate temperatures and HVAC status

## Architecture

- **7 Kubernetes nodes:**
  - 4 worker nodes (with node-exporter)
  - 3 storage nodes (Ceph, no node-exporter needed)
- **3 physical servers:**
  - Challenger, Galaxy, Yamato (Dell servers with iDRAC/Redfish)
- **Ceph cluster:** 249 TB total capacity
- **Home Assistant:** Temperature, presence, locks, power monitoring

## Deployment

### Grafana Operator (Current)

Dashboards are automatically deployed via Flux when changes are merged:

1. **JSON files** contain the dashboard definitions
2. **kustomization.yaml** generates ConfigMaps from JSON files
3. **grafanadashboard.yaml** creates `GrafanaDashboard` CRDs that reference the ConfigMaps
4. Grafana Operator watches for these CRDs and creates/updates dashboards in Grafana

To update a dashboard:
1. Edit the corresponding JSON file
2. Commit and push to the repo
3. Flux will sync and Grafana Operator will apply changes automatically

### Manual Deployment (Alternative)

If you need to deploy manually:

```bash
cd kubernetes/apps/monitoring/grafana/dashboards
kubectl apply -k .
```

## File Structure

```
dashboards/
├── 01-kubernetes.json          # Kubernetes dashboard JSON
├── 02-storage-ceph.json        # Storage & Ceph dashboard JSON
├── 03-network.json             # Network dashboard JSON
├── 04-servers.json             # Server hardware dashboard JSON
├── 05-home.json                # Home status dashboard JSON
├── grafanadashboard.yaml       # GrafanaDashboard CRDs
├── kustomization.yaml          # Kustomize config with ConfigMap generators
└── README.md                   # This file
```

## Prometheus Datasource

All dashboards reference datasource UID: `a3e5bf5e-1ea2-4461-90c7-362806abda1a`

If your Prometheus datasource has a different UID, update it in all JSON files:

```bash
NEW_UID="your-datasource-uid"
sed -i "s/a3e5bf5e-1ea2-4461-90c7-362806abda1a/$NEW_UID/g" *.json
```

## Design Notes

✨ **TV Optimized**
- Designed for 720p displays (1280×720) - no scrolling needed
- Large fonts for readability from a distance
- Color-coded thresholds (green/yellow/red)
- 45-second rotation interval

🎯 **Smart Filtering**
- Excludes broken sensors (e.g., faulty thermostat)
- Focuses on physical interfaces only (ens19)
- Shows only the 4 worker nodes with node-exporter

📊 **Complete Coverage**
- Kubernetes workloads and infrastructure
- Ceph storage cluster health
- Physical server hardware monitoring
- Home automation integration

## Grafana Operator Benefits

- **Declarative:** Dashboards defined as code in Git
- **GitOps Ready:** Automatic sync via Flux
- **Version Control:** Full history of dashboard changes
- **No Manual Import:** No need to use Grafana UI or API
- **Consistent State:** Operator ensures dashboards match desired state

## Troubleshooting

### Dashboard Not Appearing

Check the GrafanaDashboard status:
```bash
kubectl get grafanadashboard -n monitoring
kubectl describe grafanadashboard tv-kubernetes -n monitoring
```

### ConfigMap Issues

Verify ConfigMaps were created:
```bash
kubectl get configmap -n monitoring | grep grafana-dashboard
```

### Operator Logs

Check Grafana Operator logs:
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana-operator
```

## Version History

- **2026-03-06:** Initial creation with Grafana Operator CRDs
  - 5-dashboard rotation for TV display
  - Added Ceph monitoring
  - Split network into dedicated dashboard
  - Fixed temperature conversion (F)
  - Excluded broken climate sensor
  - Implemented GitOps-friendly deployment via Operator
