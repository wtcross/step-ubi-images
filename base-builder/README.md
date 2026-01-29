# UBI10 Base Builder Image

Base builder image for compiling Go applications with PKCS#11 support on UBI10. Includes meson and pcsc-lite built from source to avoid CodeReady Builder repository requirements.

## Purpose

This image serves as a build dependency for:
- `step-ca` - Requires pcsc-lite for PKCS#11 support (CGO_ENABLED=1)
- `step-kms-plugin` - Requires pcsc-lite for PKCS#11 support

## Included Components

| Component | Description |
|-----------|-------------|
| meson | Build system for pcsc-lite |
| pcsc-lite | PC/SC smart card library (built from source with GPG verification) |
| golang | Go compiler |
| gcc/g++ | C/C++ compilers |
| make | Build tool |

## Version Management

Versions are defined in `/versions.json` at the repository root:
- `meson` - Meson build system version
- `pcsc-lite` - PC/SC Lite version

Renovate automatically tracks updates from:
- `mesonbuild/meson` (GitHub releases)
- `LudovicRousseau/PCSC` (GitHub tags)

## Build

This image is built automatically by GitHub Actions when:
- Files in `base-builder/` change
- `versions.json` changes (meson or pcsc-lite versions)
- Scheduled weekly rebuild
- Manual workflow dispatch

To build locally:

```bash
podman build \
    --build-arg MESON_VERSION=1.10.0 \
    --build-arg PCSC_LITE_VERSION=2.4.1 \
    -t ubi10-builder:latest \
    -f ubi10.Containerfile \
    .
```

## Security

pcsc-lite source is verified using GPG signature from Ludovic Rousseau (maintainer):
- Key: `F5E11B9FFE911146F41D953D78A1B4DFE8F9C57E`
- Signature: Downloaded from `https://pcsclite.apdu.fr/files/`
