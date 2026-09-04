#!/usr/bin/env bash
set -euo pipefail

# Inspired by kcp-dev/kcp's 2021 demo-magic runner, but dependency-free.
UDS_BIN="${UDS_BIN:-uds}"
export CLI_FEATURES=NextMode=true
cd bundle

uds() {
  command "$UDS_BIN" "$@"
}

commands=(
  'cat bundle.uds.hcl defaults.uds.hcl'
  'cat values/alpha.yaml values/bravo.yaml'
  'export CLI_FEATURES=NextMode=true'
  'uds zarf tools gen-key'
  'uds zarf package create packages/alpha --confirm --output packages/alpha --signing-key cosign.key && uds zarf package create packages/bravo --confirm --output packages/bravo --signing-key cosign.key'
  'uds bundle create --signing-key cosign.key .'
  'uds bundle inspect --public-key cosign.pub uds-bundle-uds-next-demo-*-0.1.0.tar.zst'
  'uds bundle deploy --concurrency=2 --public-key cosign.pub uds-bundle-uds-next-demo-*-0.1.0.tar.zst'
  'kubectl -n uds-next-alpha get deployments,pods && kubectl -n uds-next-bravo get deployments,pods'
  'uds bundle remove .'
)

type_command() {
  local text="$1" character key terminal_state=""
  if [[ -t 0 ]]; then
    terminal_state=$(stty -g)
    stty -icanon -echo min 0 time 0
  fi

  for ((index = 0; index < ${#text}; index++)); do
    character="${text:index:1}"
    printf '%s' "$character"
    if [[ -n "$terminal_state" ]] && key=$(perl -MFcntl=F_GETFL,F_SETFL,O_NONBLOCK -e '
      $flags = fcntl(STDIN, F_GETFL, 0);
      fcntl(STDIN, F_SETFL, $flags | O_NONBLOCK);
      $count = sysread(STDIN, $key, 1);
      fcntl(STDIN, F_SETFL, $flags);
      exit 1 unless $count;
      print $key;
    ' 2>/dev/null); then
      if [[ -z "$key" || "$key" == ' ' ]]; then
        printf '%s' "${text:index + 1}"
        break
      fi
    fi
    sleep 0.008
  done
  [[ -n "$terminal_state" ]] && stty "$terminal_state"
  printf '\n'
}

wait_for_space() {
  local key
  while IFS= read -rsn1 key; do
    [[ -z "$key" || "$key" == ' ' ]] && return
  done
}

clear
cat <<'EOF'
▗▖ ▗▖▗▄▄▄   ▗▄▄▖     ▗▄▄▖▗▖   ▗▄▄▄▖    ▗▄▄▄  ▗▄▄▄▖▗▖  ▗▖ ▗▄▖
▐▌ ▐▌▐▌  █ ▐▌       ▐▌   ▐▌     █      ▐▌  █ ▐▌   ▐▛▚▞▜▌▐▌ ▐▌
▐▌ ▐▌▐▌  █  ▝▀▚▖    ▐▌   ▐▌     █      ▐▌  █ ▐▛▀▀▘▐▌  ▐▌▐▌ ▐▌
▝▚▄▞▘▐▙▄▄▀ ▗▄▄▞▘    ▝▚▄▄▖▐▙▄▄▖▗▄█▄▖    ▐▙▄▄▀ ▐▙▄▄▖▐▌  ▐▌▝▚▄▞▘
EOF
printf '\n\nUDS CLI contains the Better Bundles™ implementation with the following capabilities:\n'
printf '\033[34m\n'
printf '  1. HCL-native syntax — locals, templates, variables, dependencies\n'
printf '  2. One CLI for the entire workflow — author, verify, deploy, and operate\n'
printf '  3. Secure by default — verify packages, sign the full bundle\n'
printf '  4. Fast and safe — concurrent deploys with dependency DAG ordering\n'
printf '\033[0m\n'
for index in "${!commands[@]}"; do
  command="${commands[$index]}"
  printf '🦄 $ '
  wait_for_space
  type_command "$command"
  wait_for_space
  eval "$command"
  printf '\n'
done
cat <<'EOF'
 ▗▄▄▖▗▄▄▄▖▗▄▄▄▖    ▗▖  ▗▖▗▄▖ ▗▖ ▗▖     ▗▄▖ ▗▖  ▗▖     ▗▄▄▖▗▄▄▄▖▗▄▄▖▗▄▄▄▖      ▄▄▄▄ ▗▄▄▄▖▗▖ ▗▖
▐▌   ▐▌   ▐▌        ▝▚▞▘▐▌ ▐▌▐▌ ▐▌    ▐▌ ▐▌▐▛▚▖▐▌    ▐▌   ▐▌   ▐▌ ▐▌ █        █  █   █  ▐▌ ▐▌
 ▝▀▚▖▐▛▀▀▘▐▛▀▀▘      ▐▌ ▐▌ ▐▌▐▌ ▐▌    ▐▌ ▐▌▐▌ ▝▜▌     ▝▀▚▖▐▛▀▀▘▐▛▀▘  █        █▀▀█   █  ▐▛▀▜▌
▗▄▄▞▘▐▙▄▄▖▐▙▄▄▖      ▐▌ ▝▚▄▞▘▝▚▄▞▘    ▝▚▄▞▘▐▌  ▐▌    ▗▄▄▞▘▐▙▄▄▖▐▌    █ ▗▖     █▄▄█   █  ▐▌ ▐▌


EOF