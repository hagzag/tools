# [1.2.0](https://github.com/hagzag/tools/compare/v1.1.0...v1.2.0) (2026-09-30)


### Bug Fixes

* add explicit docker login for GHCR push ([de06853](https://github.com/hagzag/tools/commit/de068530973732844d3cf2d6be2349a51bed85c6))
* add test branch pattern to build-shared workflow triggers ([dc8fe9a](https://github.com/hagzag/tools/commit/dc8fe9a9f14da4863fcfd8fc1301e4951b673886))
* only compute primary image ref when pushing ([cc84066](https://github.com/hagzag/tools/commit/cc84066e58473435132d1b6e98aa87ff90899740))
* only run security scanning on pushed builds ([7bbc93e](https://github.com/hagzag/tools/commit/7bbc93e0909fbe604f56b7d3eb676e75c510c7f5))
* only run smoke tests and release on main branch ([bce4f36](https://github.com/hagzag/tools/commit/bce4f367a1c4635d2f319f67676e96d889fca354))
* update SBOM validation to check for nodejs-22 ([437c436](https://github.com/hagzag/tools/commit/437c4364ac3d6931ac5cf1b45f51ba8ea18e21f2))
* upgrade Node.js 20 to 22 and CodeQL action to v4 ([549f2cb](https://github.com/hagzag/tools/commit/549f2cb99f65bf28281c249f2f7880601fca02d2))
* use amd64-only builds on test branches to avoid QEMU issues ([01b2198](https://github.com/hagzag/tools/commit/01b2198e3cad08e88e0c4f07bf60df35617dbc84))
* use comma-separated format for docker build-args ([f4d1e84](https://github.com/hagzag/tools/commit/f4d1e84cc5b1231bd29f3d21b0b33348a92c8c04))


### Features

* add build-shared.yaml workflow using github-actions shared docker-buildx action ([73014ff](https://github.com/hagzag/tools/commit/73014ff7cd688179b96b58904dd7c0125ed7d634))


### Reverts

* use multiline format for docker build-args ([0f6f10e](https://github.com/hagzag/tools/commit/0f6f10eb5774b8e5df04c0900416ed548cf566a7))

# [1.1.0](https://github.com/hagzag/tools/compare/v1.0.0...v1.1.0) (2026-04-19)


### Features

* add dependabot for docker and npm weekly updates ([cb7d723](https://github.com/hagzag/tools/commit/cb7d72387c6eba98d404d2fcc26c5fa8adf635db))
* bump all GH Actions to node24-compatible versions ([16cb677](https://github.com/hagzag/tools/commit/16cb677f41763e89bada9a583df2ce7ec2a8d828))

# 1.0.0 (2026-04-19)


### Bug Fixes

* add missing semantic-release plugins to image ([abc9c90](https://github.com/hagzag/tools/commit/abc9c901560db37afd0c21317378d8938a37788e))
* make SBOM attestation non-fatal on Rekor network errors ([8c3ae42](https://github.com/hagzag/tools/commit/8c3ae4205e3580bacd1f77490f762ca460571d5f))
* pin grype version to avoid GitHub API rate limit on install ([6637e3f](https://github.com/hagzag/tools/commit/6637e3fdac48fdc939873d23ca5deb18a0eddb7f))
* replace anchore/scan-action with direct grype CLI run ([de5ca7a](https://github.com/hagzag/tools/commit/de5ca7a570d88fb4d56750af910d8f464f252a8d))
* Update permissions for GitHub Actions workflow ([07e366b](https://github.com/hagzag/tools/commit/07e366bca84b8361259bd648ef19a0071a7d00e8))


### Features

* initial Wolfi-based CI toolchain image ([1506c50](https://github.com/hagzag/tools/commit/1506c5041e275101c7744f1545de3ce66ba06b5b))
fix: test full security pipeline
