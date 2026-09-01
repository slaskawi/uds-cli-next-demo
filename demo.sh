#!/usr/bin/env bash
set -euo pipefail

# Inspired by kcp-dev/kcp's 2021 demo-magic runner, but dependency-free.
UDS_BIN="${UDS_BIN:-uds}"
export CLI_FEATURES=NextMode=true
artifact='bundle/uds-bundle-uds-next-demo-*-0.1.0.tar.zst'

uds() {
  command "$UDS_BIN" "$@"
}

commands=(
  'cat bundle/bundle.uds.hcl'
  'cat bundle/values/alpha.yaml bundle/values/bravo.yaml'
  'export CLI_FEATURES=NextMode=true'
  'uds zarf package create bundle/packages/alpha --confirm --output bundle/packages/alpha'
  'uds zarf package create bundle/packages/bravo --confirm --output bundle/packages/bravo'
  'uds bundle create --unsigned bundle'
  'uds bundle inspect bundle/uds-bundle-uds-next-demo-*-0.1.0.tar.zst'
  'uds bundle deploy --concurrency=2 --skip-signature-verification bundle/uds-bundle-uds-next-demo-*-0.1.0.tar.zst'
  'kubectl -n uds-next-demo get deployments,pods'
  '(cd bundle && uds bundle remove .)'
)

type_command() {
  local text="$1" character
  for ((index = 0; index < ${#text}; index++)); do
    character="${text:index:1}"
    printf '%s' "$character"
    sleep 0.012
  done
  printf '\n'
}

wait_for_space() {
  local key
  while IFS= read -rsn1 key; do
    [[ "$key" == ' ' ]] && return
  done
}

printf 'UDS CLI Next demo. Press Space to type; press Space again to run. Ctrl-C exits.\n\n'
for index in "${!commands[@]}"; do
  command="${commands[$index]}"
  printf '🦄 $ '
  wait_for_space
  type_command "$command"
  wait_for_space
  eval "$command"
  printf '\n'
done
