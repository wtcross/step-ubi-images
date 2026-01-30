# UBI10 Step Builder Image

Builder image for compiling Go applications with PKCS#11 support on UBI10. Includes m4, flex, meson and pcsc-lite built from source to avoid CodeReady Builder repository requirements.

## Purpose

This image serves as a build dependency for:
- `step-ca` - Requires pcsc-lite for PKCS#11 support (CGO_ENABLED=1)
- `step-kms-plugin` - Requires pcsc-lite for PKCS#11 support

## Included Components

| Component | Description |
|-----------|-------------|
| m4 | GNU macro processor (built from source with GPG verification) |
| flex | Lexical analyzer generator (built from source with GPG verification) |
| meson | Build system for pcsc-lite (installed from source with GPG verification) |
| pcsc-lite | PC/SC smart card library (built from source with GPG verification) |
| golang | Go compiler |
| gcc/g++ | C/C++ compilers |
| make | Build tool |
| python3 | Required for meson |
| ninja-build | Required for meson builds |
| pkgconf | Package configuration tool |

## Version Management

Versions are defined in `/versions.json` at the repository root:
- `m4` - GNU m4 macro processor version
- `flex` - Flex lexical analyzer version
- `meson` - Meson build system version
- `pcsc-lite` - PC/SC Lite version

Renovate automatically tracks updates from:
- `gnu/m4` (GNU FTP - requires manual tracking)
- `westes/flex` (GitHub releases)
- `mesonbuild/meson` (GitHub releases)
- `LudovicRousseau/PCSC` (GitHub tags)

## Build

This image is built automatically by GitHub Actions when:
- Files in `step-builder/` change
- `versions.json` changes
- Scheduled weekly rebuild
- Manual workflow dispatch

To build locally:

```bash
podman build \
    --build-arg M4_VERSION=1.4.20 \
    --build-arg FLEX_VERSION=2.6.4 \
    --build-arg MESON_VERSION=1.10.0 \
    --build-arg PCSC_LITE_VERSION=2.4.1 \
    -t step-builder:latest \
    -f ubi10.Containerfile \
    .
```

## Security

All source-built components are verified using GPG signatures:

| Component | Maintainer | GPG Key |
|-----------|------------|---------|
| m4 | Eric Blake | `A7A16B4A2527436A` |
| flex | Will Estes | `E4B29C8D64885307` |
| meson | Jussi Pakkanen | `19E2D6D9B46D8DAA6288F877C24E631BABB1FE70` |
| pcsc-lite | Ludovic Rousseau | `F5E11B9FFE911146F41D953D78A1B4DFE8F9C57E` |

See [THIRD-PARTY-NOTICES.md](/THIRD-PARTY-NOTICES.md) for license information.
