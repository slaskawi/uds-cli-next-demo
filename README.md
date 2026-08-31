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

Before a rehearsal, create the two local Zarf package artifacts:

```bash
./prepare.sh
```

Each Space press alternates between typing and running one command:

1. Show `bundle/bundle.uds.hcl` and both values files.
2. Inspect a prebuilt bundle artifact.
3. Create an unsigned local artifact.
4. Deploy it with `--concurrency=2`.
5. Show both deployed workloads.

The runner exports `CLI_FEATURES=NextMode=true` once before calling UDS. It quietly creates an artifact before the presentation because `bundle inspect` accepts artifacts or OCI references, not source directories. It removes that artifact immediately after inspection, so the visible create command produces the deployed artifact.

## Why parallel deploy is visible

`alpha` and `bravo` have no `depends_on` relationship in `bundle/bundle.uds.hcl`; both are in DAG level zero. `--concurrency=2` therefore starts both package deploys together. They share `registry.k8s.io/pause:3.10`, a very small public image, minimizing the first-pull delay.

## Manual runbook

```bash
cat bundle/bundle.uds.hcl
cat bundle/values/alpha.yaml bundle/values/bravo.yaml
export CLI_FEATURES=NextMode=true
./prepare.sh
uds bundle create --unsigned bundle
uds bundle inspect bundle/uds-bundle-uds-next-demo-*-0.1.0.tar.zst
rm -f bundle/uds-bundle-uds-next-demo-*.tar.zst
uds bundle create --unsigned bundle
uds bundle deploy --concurrency=2 --skip-signature-verification bundle/uds-bundle-uds-next-demo-*-0.1.0.tar.zst
kubectl -n uds-next-demo get deployments,pods
```

The artifact glob selects the single architecture-specific artifact created on the laptop.

## Cleanup

Remove only this demo's two Zarf releases, namespace, and generated artifacts:

```bash
./cleanup.sh
```

`cleanup.sh` does not create, delete, or reconfigure the Kubernetes cluster. Set the same `UDS_BIN` override when using an unreleased NextMode build.

The keyboard runner is a small, dependency-free adaptation of [kcp-dev/kcp's `demo-magic`](https://github.com/kcp-dev/kcp/blob/c00212d7b487ba17212e6cd8917b26a60fa80de3/contrib/demo/demo-magic), the 2021 script that types and executes staged demo commands.
