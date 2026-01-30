# Minimal step-kms-plugin image with PKCS#11 support
# Contains step-kms-plugin and step-cli for HSM key and certificate operations

ARG BASE_BUILDER_IMAGE=ghcr.io/wtcross/step-builder:latest
FROM ${BASE_BUILDER_IMAGE} AS kms-builder

# NOTE: step-kms-plugin does not provide cosign-signed source tarballs.
# The release only includes checksums.txt and pre-built binaries (no .sig/.pem files).
# Using git clone with tag provides SHA-based integrity via git.
ARG STEP_KMS_PLUGIN_TAG
RUN git clone --branch "${STEP_KMS_PLUGIN_TAG}" --single-branch --depth 1 https://github.com/smallstep/step-kms-plugin.git /opt/app-root/src/step-kms-plugin
WORKDIR /opt/app-root/src/step-kms-plugin

RUN make V=1 build

# Use pre-built step-cli from signed image
ARG STEP_CLI_IMAGE=ghcr.io/wtcross/step-cli:latest
FROM ${STEP_CLI_IMAGE} AS step-cli

# Create minimal rootfs with p11-kit client libraries
FROM registry.access.redhat.com/ubi10/ubi AS rootfs-builder

RUN mkdir -p /mnt/rootfs
RUN mkdir -p /mnt/rootfs/usr/lib64 /mnt/rootfs/usr/bin /mnt/rootfs/usr/sbin /mnt/rootfs/usr/lib \
    && ln -s usr/lib64 /mnt/rootfs/lib64 \
    && ln -s usr/bin   /mnt/rootfs/bin \
    && ln -s usr/sbin  /mnt/rootfs/sbin \
    && ln -s usr/lib   /mnt/rootfs/lib

RUN dnf install -y \
    --nodocs \
    --installroot /mnt/rootfs \
    --releasever=10 \
    --setopt=install_weak_deps=false \
    p11-kit gnutls-utils \
    && dnf clean all --installroot /mnt/rootfs
RUN rm -rf /mnt/rootfs/var/cache/* /mnt/rootfs/var/log/*

# Create step user for OpenShift compatibility
RUN useradd --root /mnt/rootfs -m -d /home/step -s /sbin/nologin -u 1001 step \
    && chown -R 1001:0 /mnt/rootfs/home/step \
    && chmod -R g+w /mnt/rootfs/home/step

# Create PKCS#11 socket mount point
RUN mkdir -p /mnt/rootfs/run/pkcs11-socket \
    && chown 1001:0 /mnt/rootfs/run/pkcs11-socket \
    && chmod 755 /mnt/rootfs/run/pkcs11-socket

FROM registry.access.redhat.com/ubi10/ubi-micro

ARG STEP_KMS_PLUGIN_TAG

LABEL io.smallstep.step-kms-plugin.version="${STEP_KMS_PLUGIN_TAG}"

COPY --from=rootfs-builder /mnt/rootfs /
COPY --from=kms-builder /opt/app-root/src/step-kms-plugin/bin/step-kms-plugin /usr/local/bin/step-kms-plugin
COPY --from=step-cli /usr/local/bin/step /usr/local/bin/step

ENV P11_KIT_SERVER_ADDRESS="unix:path=/run/pkcs11-socket"

USER 1001
WORKDIR /home/step
