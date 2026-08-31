#!/usr/bin/env bash
set -euo pipefail

UDS_BIN="${UDS_BIN:-uds}"

for package in alpha bravo; do
  "$UDS_BIN" zarf package create "bundle/packages/$package" --confirm --output "bundle/packages/$package"
done
