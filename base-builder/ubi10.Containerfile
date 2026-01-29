# Base builder image with meson and pcsc-lite built from source
# Avoids CodeReady Builder repo requirement for pcsc-lite-devel

FROM registry.access.redhat.com/ubi10/ubi

ARG MESON_VERSION
ARG PCSC_LITE_VERSION
# Jussi Pakkanen's GPG key (meson maintainer) - https://github.com/mesonbuild/meson/releases
ARG MESON_GPG_KEY="95181F4EED14FDF4E41B518D3BF1B0DE4B24E0C5"
# Ludovic Rousseau's GPG key (pcsc-lite maintainer) - https://pcsclite.apdu.fr/
ARG PCSC_LITE_GPG_KEY="F5E11B9FFE911146F41D953D78A1B4DFE8F9C57E"

# Install base build dependencies
RUN dnf install -y --nodocs \
    make gcc g++ pkgconf golang gnupg2 xz \
    python3 ninja-build flex \
    && dnf clean all

# Install meson from GitHub releases with GPG verification
RUN curl -sSfL "https://github.com/mesonbuild/meson/releases/download/${MESON_VERSION}/meson-${MESON_VERSION}.tar.gz" -o /tmp/meson.tar.gz \
    && curl -sSfL "https://github.com/mesonbuild/meson/releases/download/${MESON_VERSION}/meson-${MESON_VERSION}.tar.gz.asc" -o /tmp/meson.tar.gz.asc \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys "${MESON_GPG_KEY}" \
    && gpg --verify /tmp/meson.tar.gz.asc /tmp/meson.tar.gz \
    && tar -xzf /tmp/meson.tar.gz -C /opt \
    && ln -s /opt/meson-${MESON_VERSION}/meson.py /usr/local/bin/meson \
    && rm -rf /tmp/meson*

# Build and install pcsc-lite from source with GPG verification
RUN curl -sSfL "https://pcsclite.apdu.fr/files/pcsc-lite-${PCSC_LITE_VERSION}.tar.xz" -o /tmp/pcsc-lite.tar.xz \
    && curl -sSfL "https://pcsclite.apdu.fr/files/pcsc-lite-${PCSC_LITE_VERSION}.tar.xz.asc" -o /tmp/pcsc-lite.tar.xz.asc \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys "${PCSC_LITE_GPG_KEY}" \
    && gpg --verify /tmp/pcsc-lite.tar.xz.asc /tmp/pcsc-lite.tar.xz \
    && tar -xf /tmp/pcsc-lite.tar.xz -C /tmp \
    && cd /tmp/pcsc-lite-${PCSC_LITE_VERSION} \
    && meson setup build --prefix=/usr -Dlibsystemd=false -Dlibudev=false -Dpolkit=false \
    && meson compile -C build \
    && meson install -C build \
    && rm -rf /tmp/pcsc-lite* \
    && ldconfig

LABEL io.smallstep.meson.version="${MESON_VERSION}" \
      io.smallstep.pcsc-lite.version="${PCSC_LITE_VERSION}"
