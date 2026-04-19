# backlog

## security posture

- [ ] enable dependabot vulnerability alerts
- [ ] add `dependabot.yml` for docker + npm auto-update PRs
- [ ] enable dependabot security updates (auto-PR on CVE fix)
- [ ] enable `secret_scanning_non_provider_patterns`
- [ ] enable `secret_scanning_validity_checks`
- [ ] resolve `brace-expansion` Medium (GHSA-f886-m6hf-6m8v) — suppress in `.grype.yaml` or wait for upstream semantic-release fix

## actions / workflow hygiene

- [ ] update actions to node24-compatible versions (deadline: June 2026)
  - `actions/checkout@v4` → v5 (when available)
  - `docker/build-push-action@v6`
  - `docker/login-action@v3`
  - `docker/metadata-action@v5`
  - `docker/setup-buildx-action@v3`
  - `docker/setup-qemu-action@v3`
  - `github/codeql-action/upload-sarif@v3` → v4 (deprecated dec 2026)
