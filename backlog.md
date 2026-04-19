# backlog

## security posture

- [ ] enable dependabot vulnerability alerts
- [ ] add `dependabot.yml` for docker + npm auto-update PRs
- [ ] enable dependabot security updates (auto-PR on CVE fix)
- [ ] enable `secret_scanning_non_provider_patterns`
- [ ] enable `secret_scanning_validity_checks`
- [ ] resolve `brace-expansion` Medium (GHSA-f886-m6hf-6m8v) — suppress in `.grype.yaml` or wait for upstream semantic-release fix

## actions / workflow hygiene

- [x] update actions to node24-compatible versions
  - `actions/checkout@v4` → v6
  - `docker/build-push-action@v6` → v7
  - `docker/login-action@v3` → v4
  - `docker/metadata-action@v5` → v6
  - `docker/setup-buildx-action@v3` → v4
  - `docker/setup-qemu-action@v3` → v4
  - `github/codeql-action/upload-sarif@v3` → v4
  - `actions/upload-artifact@v4` → v7
  - `sigstore/cosign-installer@v3` — kept (no v4 major tag yet)
