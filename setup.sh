#!/usr/bin/env bash
set -euo pipefail

# Boot the official local UDS Core demo. Override CORE_BUNDLE to pin a release.
CORE_BUNDLE="${CORE_BUNDLE:-k3d-core-demo:latest}"

for command in uds kubectl docker; do
  command -v "$command" >/dev/null || {
    echo "Missing required command: $command" >&2
    exit 1
  }
done

if kubectl cluster-info >/dev/null 2>&1; then
  echo "A Kubernetes cluster is already reachable. Refusing to replace it."
  echo "Use that cluster for the demo, or switch kubectl to an empty context."
  exit 0
fi

echo "Booting UDS Core from ${CORE_BUNDLE}..."
uds deploy "$CORE_BUNDLE" --confirm

kubectl cluster-info
kubectl get nodes
