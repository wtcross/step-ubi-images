# step-ubi-images

UBI10-based container images for running Smallstep tools with PKCS#11/HSM support.

## Overview

This repository provides container images for operating a PKI with hardware security module (HSM) integration. The images are built on Red Hat UBI10 and include PKCS#11 support for secure private key operations.

## Disclaimer

These images are **not distributed or signed by Smallstep**. The official Smallstep container images are built without CGO, which means they lack PKCS#11 support. These images are compiled with `CGO_ENABLED=1` to enable HSM integration.

For more information on PKCS#11 requirements, see the [Smallstep documentation on cryptographic protection](https://smallstep.com/docs/step-ca/cryptographic-protection/#pkcs-11).

If you prefer not to trust third-party container images, you can use the Containerfiles in this repository to build your own.

## Images

| Image | Purpose | Documentation |
|-------|---------|---------------|
| `step-builder` | Builder image with PKCS#11 dependencies (m4, flex, meson, pcsc-lite) for compiling Go apps with HSM support | [step-builder/README.md](step-builder/README.md) |
| `step-ca` | Certificate Authority with PKCS#11/HSM support for intermediate CA operations | [step-ca/README.md](step-ca/README.md) |
| `step-kms-plugin` | HSM key and certificate operations (root CA setup, intermediate CSR signing) | [step-kms-plugin/README.md](step-kms-plugin/README.md) |
| `step-cli` | CA administration tool for provisioner and policy management | [step-cli/README.md](step-cli/README.md) |

## Version Management

Component versions are defined in [`versions.json`](versions.json) at the repository root. [Renovate](https://docs.renovatebot.com/) automatically tracks updates from upstream sources.

## Security

### Source Verification

- **Source-built components** (m4, flex, meson, pcsc-lite): Verified using GPG signatures from upstream maintainers
- **Smallstep sources** (step-ca, step-cli): Verified using [cosign](https://github.com/sigstore/cosign) before compilation

### Build Process

Images are built automatically by GitHub Actions with:
- Multi-stage builds to minimize final image size
- Non-root user execution
- Verification of all source artifacts before compilation

## License

See [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for license information on source-built components.
