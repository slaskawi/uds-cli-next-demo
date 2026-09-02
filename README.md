# UDS CLI Next: three-minute demo

This demo inspects, creates, and deploys a UDS bundle to a running UDS Core cluster. The two packages are independent, so the final command deploys them concurrently.

## Prerequisites

- `uds` containing the alpha `NextMode` feature.
- Docker and `kubectl`.
- A reachable UDS Core cluster, or enough laptop resources to create one.
- A UDS CLI build containing alpha NextMode bundle commands. Homebrew `uds v0.36.0` is the latest formula at the time of this demo, but does not yet include `bundle`; point `UDS_BIN` at a current source build.

## 1. Start UDS Core

```bash
./setup.sh
```

`setup.sh` invokes the UDS Core project's supported local-demo command, `uds deploy k3d-core-demo:latest --confirm`. It exits without changing anything when `kubectl` already reaches a cluster. Pin `CORE_BUNDLE` when rehearsing a particular Core release.

```bash
CORE_BUNDLE=k3d-core-demo:<version> ./setup.sh
```

## 2. Present the demo

```bash
UDS_BIN=/path/to/current/uds ./demo.sh
```

Each Space or Enter press alternates between typing and running one command. Press either key while a command is typing to finish it immediately.

1. Show the bundle definition, artifact defaults, and values templates.
2. Generate an ephemeral Cosign key pair with the bundled Zarf tool.
3. Build and sign both packages in one stage.
4. Create a signed local bundle artifact.
5. Verify and inspect the artifact with its public key.
6. Verify and concurrently deploy the artifact defaults.
7. Show both deployed workloads and their resolved values.
8. Remove the demo packages.

The runner changes to `bundle/` before running its commands and exports `CLI_FEATURES=NextMode=true` once before calling UDS. At both `uds zarf tools gen-key` prompts, press Enter to create an empty-passphrase key used only by this demo; cleanup removes it. Both package builds run in one staged command.

`defaults.uds.hcl` supplies both package messages. The values files render them with `{{ .vars.alpha_message }}` and `{{ .vars.bravo_message }}`, then the packages read `{{ .Values.MESSAGE }}`. The artifact stores `defaults.uds.hcl` as a bundle-definition OCI layer, and the final labels show those embedded values. Both package blocks verify the generated `cosign.pub` during bundle creation, and inspect reports the packages and bundle as signed.

## Why parallel deploy is visible

`alpha` and `bravo` have no `depends_on` relationship in `bundle/bundle.uds.hcl`; both are in DAG level zero. `--concurrency=2` therefore starts both package deploys together. They use separate namespaces, so Zarf creates each namespace without a shared-namespace race. They share `registry.k8s.io/pause:3.10`, a very small public image, minimizing the first-pull delay.

## Manual runbook

```bash
cd bundle
cat bundle.uds.hcl defaults.uds.hcl
cat values/alpha.yaml values/bravo.yaml
export CLI_FEATURES=NextMode=true
uds zarf tools gen-key
uds zarf package create packages/alpha --confirm --output packages/alpha --signing-key cosign.key && uds zarf package create packages/bravo --confirm --output packages/bravo --signing-key cosign.key
uds bundle create --signing-key cosign.key .
uds bundle inspect --public-key cosign.pub uds-bundle-uds-next-demo-*-0.1.0.tar.zst
uds bundle deploy --concurrency=2 --public-key cosign.pub uds-bundle-uds-next-demo-*-0.1.0.tar.zst
kubectl -n uds-next-alpha get deployments,pods && kubectl -n uds-next-bravo get deployments,pods
kubectl -n uds-next-alpha get deployment alpha -o custom-columns=NAME:.metadata.name,RESOLVED_MESSAGE:.spec.template.metadata.labels.demo-message && kubectl -n uds-next-bravo get deployment bravo -o custom-columns=NAME:.metadata.name,RESOLVED_MESSAGE:.spec.template.metadata.labels.demo-message
uds bundle remove .
```

The artifact glob selects the single architecture-specific artifact created on the laptop.

## Cleanup

Remove only this demo's two Zarf releases, namespaces, and generated artifacts:

```bash
./cleanup.sh
```

`cleanup.sh` does not create, delete, or reconfigure the Kubernetes cluster. Set the same `UDS_BIN` override when using an unreleased NextMode build.

The keyboard runner is a small, dependency-free adaptation of [kcp-dev/kcp's `demo-magic`](https://github.com/kcp-dev/kcp/blob/c00212d7b487ba17212e6cd8917b26a60fa80de3/contrib/demo/demo-magic), the 2021 script that types and executes staged demo commands.
