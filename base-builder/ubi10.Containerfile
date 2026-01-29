# Base builder image with m4, flex, meson and pcsc-lite built from source
# Avoids CodeReady Builder repo requirement for pcsc-lite-devel

FROM registry.access.redhat.com/ubi10/ubi

ARG M4_VERSION
ARG FLEX_VERSION
ARG MESON_VERSION
ARG PCSC_LITE_VERSION
# Eric Blake's GPG key (GNU m4 maintainer) - https://ftpmirror.gnu.org/gnu/m4/
ARG M4_GPG_KEY="A7A16B4A2527436A"
# Will Estes' GPG key (flex maintainer) - https://github.com/westes/flex/releases
ARG FLEX_GPG_KEY="E4B29C8D64885307"
# Jussi Pakkanen's GPG key (meson maintainer) - https://github.com/mesonbuild/meson/releases
ARG MESON_GPG_KEY="19E2D6D9B46D8DAA6288F877C24E631BABB1FE70"
# Ludovic Rousseau's GPG key (pcsc-lite maintainer) - https://pcsclite.apdu.fr/
ARG PCSC_LITE_GPG_KEY="F5E11B9FFE911146F41D953D78A1B4DFE8F9C57E"

# Install base build dependencies
RUN dnf install -y --nodocs \
    make gcc g++ pkgconf golang gnupg2 xz \
    python3 ninja-build \
    && dnf clean all

# Build and install m4 from source with GPG verification
RUN curl -sSfL "https://ftpmirror.gnu.org/gnu/m4/m4-${M4_VERSION}.tar.gz" -o /tmp/m4.tar.gz \
    && curl -sSfL "https://ftpmirror.gnu.org/gnu/m4/m4-${M4_VERSION}.tar.gz.sig" -o /tmp/m4.tar.gz.sig \
    && (gpg --keyserver keyserver.ubuntu.com --recv-keys "${M4_GPG_KEY}" || gpg --keyserver keys.openpgp.org --recv-keys "${M4_GPG_KEY}") \
    && gpg --verify /tmp/m4.tar.gz.sig /tmp/m4.tar.gz \
    && tar -xzf /tmp/m4.tar.gz -C /tmp \
    && cd /tmp/m4-${M4_VERSION} \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/m4* \
    && gpgconf --kill all

# Build and install flex from source with GPG verification
RUN curl -sSfL "https://github.com/westes/flex/releases/download/v${FLEX_VERSION}/flex-${FLEX_VERSION}.tar.gz" -o /tmp/flex.tar.gz \
    && curl -sSfL "https://github.com/westes/flex/releases/download/v${FLEX_VERSION}/flex-${FLEX_VERSION}.tar.gz.sig" -o /tmp/flex.tar.gz.sig \
    && (gpg --keyserver keyserver.ubuntu.com --recv-keys "${FLEX_GPG_KEY}" || gpg --keyserver keys.openpgp.org --recv-keys "${FLEX_GPG_KEY}") \
    && gpg --verify /tmp/flex.tar.gz.sig /tmp/flex.tar.gz \
    && tar -xzf /tmp/flex.tar.gz -C /tmp \
    && cd /tmp/flex-${FLEX_VERSION} \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/flex* \
    && gpgconf --kill all

# Install meson from GitHub releases with GPG verification
RUN curl -sSfL "https://github.com/mesonbuild/meson/releases/download/${MESON_VERSION}/meson-${MESON_VERSION}.tar.gz" -o /tmp/meson.tar.gz \
    && curl -sSfL "https://github.com/mesonbuild/meson/releases/download/${MESON_VERSION}/meson-${MESON_VERSION}.tar.gz.asc" -o /tmp/meson.tar.gz.asc \
    && (gpg --keyserver keyserver.ubuntu.com --recv-keys "${MESON_GPG_KEY}" || gpg --keyserver keys.openpgp.org --recv-keys "${MESON_GPG_KEY}") \
    && gpg --verify /tmp/meson.tar.gz.asc /tmp/meson.tar.gz \
    && tar -xzf /tmp/meson.tar.gz -C /opt \
    && ln -s /opt/meson-${MESON_VERSION}/meson.py /usr/local/bin/meson \
    && rm -rf /tmp/meson* \
    && gpgconf --kill all

# Build and install pcsc-lite from source with GPG verification
RUN curl -sSfL "https://pcsclite.apdu.fr/files/pcsc-lite-${PCSC_LITE_VERSION}.tar.xz" -o /tmp/pcsc-lite.tar.xz \
    && curl -sSfL "https://pcsclite.apdu.fr/files/pcsc-lite-${PCSC_LITE_VERSION}.tar.xz.asc" -o /tmp/pcsc-lite.tar.xz.asc \
    && (gpg --keyserver keyserver.ubuntu.com --recv-keys "${PCSC_LITE_GPG_KEY}" || gpg --keyserver keys.openpgp.org --recv-keys "${PCSC_LITE_GPG_KEY}") \
    && gpg --verify /tmp/pcsc-lite.tar.xz.asc /tmp/pcsc-lite.tar.xz \
    && tar -xf /tmp/pcsc-lite.tar.xz -C /tmp \
    && cd /tmp/pcsc-lite-${PCSC_LITE_VERSION} \
    && meson setup build --prefix=/usr -Dlibsystemd=false -Dlibudev=false -Dpolkit=false \
    && meson compile -C build \
    && meson install -C build \
    && rm -rf /tmp/pcsc-lite* \
    && ldconfig \
    && gpgconf --kill all

LABEL io.smallstep.m4.version="${M4_VERSION}" \
      io.smallstep.flex.version="${FLEX_VERSION}" \
      io.smallstep.meson.version="${MESON_VERSION}" \
      io.smallstep.pcsc-lite.version="${PCSC_LITE_VERSION}"
