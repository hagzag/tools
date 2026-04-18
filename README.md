# hagzag/tools

Wolfi-based CI toolchain image for Terraform / Terragrunt / AWS pipelines.

Published as `ghcr.io/hagzag/tools` — multi-arch (`linux/amd64`, `linux/arm64`),
SBOM-attested, and cosign-signed (keyless OIDC).

## Why Wolfi?

Wolfi is a Linux *undistro* from Chainguard designed from the ground up for
containers and a supply-chain-first workflow. For a CI image this matters in
concrete ways:

- **Near-zero CVE surface.** Wolfi ships only the packages you ask for, built
  from source in a hermetic pipeline with glibc. No legacy bloat — no `perl`,
  `python`, or distro init system leaking in — which means `grype` typically
  reports zero high/critical findings on a fresh build. Compare that with a
  `ubuntu:22.04` CI image, which comes pre-loaded with ~100 packages you
  aren't using but still have to patch.

- **Every package has a signed SBOM at the source.** Wolfi's apk repo emits
  per-package SBOMs; when `syft` scans this image the graph is complete and
  traceable back to Chainguard's build. That's what makes `cosign attest`
  meaningful instead of theatre.

- **Daily rebuilds, semver-fast updates.** Wolfi's catalog updates daily —
  often within hours of upstream security fixes. Pinning `aws-cli-2` or
  `nodejs-20` gives you the current secure minor without manual chasing.

- **glibc, not musl.** Unlike Alpine, Wolfi uses glibc, so Terraform
  providers, AWS CLI, and `node-gyp` builds behave exactly like on a
  standard Linux runner. No "works on Ubuntu, breaks in container" bugs from
  musl-specific DNS resolution or `getaddrinfo` quirks.

- **Rootless-friendly, small, predictable.** `cgr.dev/chainguard/wolfi-base`
  is ~10 MB. Layer sizes are deterministic. Multi-arch builds (amd64/arm64)
  are first-class. Great fit for GitHub Actions `container:` jobs and for
  local laptop rebuilds.

The combined effect: the image is easy to audit (small SBOM), cheap to keep
green (few CVEs to chase), and fast to pull in pipelines.

## What's inside

| Tool | Source |
| --- | --- |
| `terraform` | HashiCorp release binary, version pinned by `TERRAFORM_VERSION` |
| `terragrunt` | Gruntwork release binary, version pinned by `TERRAGRUNT_VERSION` |
| `aws` (v2) | Wolfi apk `aws-cli-2` |
| `jq` | Wolfi apk |
| `git`, `bash`, `curl`, `unzip`, `ca-certificates` | Wolfi apk |
| `node` + `npm` | Wolfi apk `nodejs-20`, `npm` |
| `semantic-release` | npm global |
| `@semantic-release/commit-analyzer` | npm global |
| `@semantic-release/release-notes-generator` | npm global |
| `@semantic-release/github` | npm global |
| `@semantic-release/gitlab` | npm global |

Tool checksums are verified against the publisher's `SHA256SUMS` during build.

## Tags

| Tag | Meaning |
| --- | --- |
| `latest` | Head of `main` |
| `sha-<7char>` | Exact commit |
| `tf<ver>-tg<ver>` | Pinned toolchain version pair |

## Using from a GitHub Actions workflow

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/hagzag/tools:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - uses: actions/checkout@v4
      - run: terraform -version
      - run: terragrunt --version
```

## Verifying the image

```bash
# Cosign keyless verify (built from main on GitHub Actions)
cosign verify ghcr.io/hagzag/tools:latest \
  --certificate-identity-regexp "^https://github.com/hagzag/tools/" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"

# Download attached SBOM attestation
cosign download attestation ghcr.io/hagzag/tools:latest \
  | jq -r '.payload | @base64d' | jq '.predicate' > sbom.spdx.json
```

## Bumping tool versions

Edit `TERRAFORM_VERSION` / `TERRAGRUNT_VERSION` in **both**
`.github/workflows/build.yml` and `Taskfile.yaml` → open PR → merge.
semantic-release cuts the image release on merge to `main`.

Current pins: Terraform **1.14.8**, Terragrunt **1.0.1**.

## Local build (Taskfile)

```bash
task              # list targets
task build        # single-arch local build (loads into docker)
task smoke        # verify every tool inside the image
task sbom         # syft SBOM + content validation
task scan         # grype scan (fails on high+)
task all          # lint -> build -> smoke -> sbom -> scan
task push         # multi-arch push to ghcr.io (needs GHCR_USER / GHCR_PAT or prior docker login)
```

Requires: [Task](https://taskfile.dev), Docker (with buildx), and
optionally `syft`, `grype`, `cosign`, `hadolint`, `yamllint`.
