# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## What this repo is

Wolfi-based CI toolchain Docker image published as `ghcr.io/hagzag/tools`. Multi-arch (amd64/arm64), SBOM-attested, cosign-signed. Releases are cut automatically by semantic-release on merge to `main`.

## Common commands

```bash
task              # list all targets
task build        # single-arch local build (loads into local docker)
task smoke        # verify every tool inside the locally-built image
task lint         # hadolint (Dockerfile) + yamllint (.github/workflows/, Taskfile.yaml, .releaserc.yml)
task sbom         # syft SBOM (SPDX + CycloneDX) + content validation
task scan         # grype vulnerability scan — fails on high+
task all          # lint -> build -> smoke -> sbom -> scan
task push         # multi-arch push to ghcr.io (needs GHCR_USER + GHCR_PAT or prior docker login)
task install-tools  # install syft, grype, cosign, hadolint, yamllint if missing
```

## Version pins

Tool versions are pinned in **two places** that must stay in sync:

- `Taskfile.yaml` — `vars.TERRAFORM_VERSION`, `vars.TERRAGRUNT_VERSION`, `vars.SEMANTIC_RELEASE_VERSION`
- `.github/workflows/build.yml` — `env.TERRAFORM_VERSION`, `env.TERRAGRUNT_VERSION`, `env.SEMANTIC_RELEASE_VERSION`

When bumping versions, update both files in the same PR.

Current pins: Terraform **1.14.8**, Terragrunt **1.0.1**, semantic-release **24.2.3**.

## Release flow

Releases are fully automated:

1. Merge to `main` triggers `.github/workflows/build.yml`
2. Workflow builds multi-arch image, generates SBOM (syft), scans (grype), signs (cosign keyless OIDC), attests SBOM
3. `release` job runs `semantic-release` inside the freshly-built image using `.releaserc.yml`
4. semantic-release analyzes conventional commits → cuts GitHub release + version tag

The `dev` branch produces pre-releases. No manual tagging needed.

## Image architecture

```
Dockerfile
└── FROM cgr.dev/chainguard/wolfi-base
    ├── apk: bash, ca-certificates, curl, git, jq, unzip, aws-cli-2, nodejs-20, npm
    ├── binary: terraform (HashiCorp releases, SHA256 verified)
    ├── binary: terragrunt (Gruntwork releases, SHA256 verified)
    └── npm -g: semantic-release + 4 plugins (commit-analyzer, release-notes-generator, github, gitlab)
```

All binaries are checksum-verified during build. The image runs as root (required for GitHub Actions `container:` jobs).

## Image tags

| Tag | Meaning |
|-----|---------|
| `latest` | head of `main` |
| `sha-<7char>` | exact commit |
| `tf<ver>-tg<ver>` | pinned toolchain version pair |

## Linting rules

`task lint` runs:
- `hadolint Dockerfile`
- `yamllint` with relaxed config (line-length disabled, truthy check-keys disabled) on `.github/workflows/`, `Taskfile.yaml`, `.releaserc.yml`

## SBOM validation

`task sbom` asserts these packages appear in the SPDX output:
- apk: `aws-cli-2`, `jq`, `nodejs-20`, `npm`, `ca-certificates`, `git`, `bash`
- npm: `semantic-release`, `@semantic-release/commit-analyzer`, `@semantic-release/release-notes-generator`, `@semantic-release/github`, `@semantic-release/gitlab`
