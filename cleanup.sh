#!/usr/bin/env bash
set -euo pipefail

# Removes only this demo's Zarf releases, namespaces, and local artifacts.
# It never creates, deletes, or reconfigures the Kubernetes cluster.
UDS_BIN="${UDS_BIN:-uds}"
export CLI_FEATURES=NextMode=true

cd bundle

"$UDS_BIN" bundle remove .
kubectl delete namespace uds-next-alpha uds-next-bravo --ignore-not-found
rm -f uds-bundle-uds-next-demo-*.tar.zst
rm -f packages/alpha/zarf-package-uds-next-alpha-*.tar.zst
rm -f packages/bravo/zarf-package-uds-next-bravo-*.tar.zst
rm -f cosign.key cosign.pub
