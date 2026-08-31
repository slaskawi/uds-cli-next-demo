#!/usr/bin/env bash
set -euo pipefail

# Removes only this demo's Zarf releases, namespace, and local artifacts.
# It never creates, deletes, or reconfigures the Kubernetes cluster.
UDS_BIN="${UDS_BIN:-uds}"
export CLI_FEATURES=NextMode=true

(
  cd bundle
  "$UDS_BIN" bundle remove .
)
kubectl delete namespace uds-next-demo --ignore-not-found
rm -f bundle/uds-bundle-uds-next-demo-*.tar.zst
rm -f bundle/packages/alpha/zarf-package-uds-next-alpha-*.tar.zst
rm -f bundle/packages/bravo/zarf-package-uds-next-bravo-*.tar.zst
