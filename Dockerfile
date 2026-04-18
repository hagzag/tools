# syntax=docker/dockerfile:1.7
#
# Wolfi-based CI toolchain for Terraform / Terragrunt / AWS / semantic-release.
#
# Built and published as ghcr.io/hagzag/tools by .github/workflows/build.yml.
# Pinned versions are supplied via build args from the workflow env block so
# version bumps happen in one place (the workflow).

ARG WOLFI_BASE=cgr.dev/chainguard/wolfi-base:latest
FROM ${WOLFI_BASE}

ARG TARGETOS
ARG TARGETARCH
ARG TERRAFORM_VERSION
ARG TERRAGRUNT_VERSION
ARG NODE_MAJOR=20
ARG SEMANTIC_RELEASE_VERSION=24.2.3

SHELL ["/bin/sh", "-eu", "-o", "pipefail", "-c"]
# hadolint ignore=DL3002
USER root

# --- OS packages ---------------------------------------------------------
# aws-cli-v2  -> full AWS CLI v2
# nodejs-20+npm -> runtime for semantic-release
# jq / git / bash / curl / unzip / ca-certs -> table-stakes
# hadolint ignore=DL3018
RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      unzip \
      aws-cli-2 \
      nodejs-${NODE_MAJOR} \
      npm \
 && rm -rf /var/cache/apk/*

# --- Terraform (pinned binary from HashiCorp releases) -------------------
# hadolint ignore=DL3003,DL4006
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) tf_arch=amd64 ;; \
      arm64) tf_arch=arm64 ;; \
      *)     echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/tf.zip \
      "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${tf_arch}.zip"; \
    curl -fsSL -o /tmp/tf.sha \
      "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS"; \
    expected=$(grep "terraform_${TERRAFORM_VERSION}_linux_${tf_arch}.zip" /tmp/tf.sha | awk '{print $1}'); \
    actual=$(sha256sum /tmp/tf.zip | awk '{print $1}'); \
    [ "$expected" = "$actual" ]; \
    unzip -q /tmp/tf.zip -d /usr/local/bin; \
    chmod +x /usr/local/bin/terraform; \
    rm -f /tmp/tf.zip /tmp/tf.sha; \
    terraform -version

# --- Terragrunt (pinned binary from Gruntwork releases) ------------------
# hadolint ignore=DL3003,DL4006
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) tg_arch=amd64 ;; \
      arm64) tg_arch=arm64 ;; \
      *)     echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/terragrunt \
      "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${tg_arch}"; \
    curl -fsSL -o /tmp/tg.sha \
      "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS"; \
    (cd /usr/local/bin && \
       expected=$(grep "terragrunt_linux_${tg_arch}$" /tmp/tg.sha | awk '{print $1}') && \
       actual=$(sha256sum terragrunt | awk '{print $1}') && \
       [ "$expected" = "$actual" ]); \
    chmod +x /usr/local/bin/terragrunt; \
    rm -f /tmp/tg.sha; \
    terragrunt --version

# --- semantic-release + required plugins --------------------------------
# Installed globally so `semantic-release` is on PATH and plugins resolve
# via the global node_modules directory.
# hadolint ignore=DL3016
RUN set -eux; \
    npm config set update-notifier false; \
    npm install -g --omit=dev --no-fund --no-audit \
      "semantic-release@${SEMANTIC_RELEASE_VERSION}" \
      @semantic-release/commit-analyzer \
      @semantic-release/release-notes-generator \
      @semantic-release/changelog \
      @semantic-release/git \
      @semantic-release/exec \
      @semantic-release/github \
      @semantic-release/gitlab; \
    npm cache clean --force; \
    semantic-release --version; \
    npm ls -g --depth=0

# --- OCI labels (populated further by workflow via --label) --------------
LABEL org.opencontainers.image.source="https://github.com/hagzag/tools" \
      org.opencontainers.image.description="Wolfi-based CI image: terraform, terragrunt, aws-cli v2, jq, semantic-release (+ changelog/git/exec/github/gitlab plugins)" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="hagzag" \
      io.hagzag.tools.terraform="${TERRAFORM_VERSION}" \
      io.hagzag.tools.terragrunt="${TERRAGRUNT_VERSION}" \
      io.hagzag.tools.semantic-release="${SEMANTIC_RELEASE_VERSION}"

WORKDIR /work

# GitHub Actions container jobs need a shell on PATH and expect root by
# default (workspace is mounted as root). Keep root; drop privileges in
# consumer workflows if desired.
CMD ["/bin/bash"]
