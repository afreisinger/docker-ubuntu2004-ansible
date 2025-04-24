FROM ubuntu:20.04

LABEL org.opencontainers.image.description="${DESCRIPTION}"

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}

ARG pip_packages="ansible"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Install base system packages
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        curl \
        dnsutils \
        gnupg \
        gnupg-agent \
        iproute2 \
        iputils-ping \
        libpam-radius-auth \
        locales \
        net-tools \
        python3 \
        python3-pip \
        rsyslog \
        software-properties-common \
        sudo \
        systemd \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc && rm -rf /usr/share/man

# Copy the initctl shim
COPY initctl-shim /initctl-shim
COPY /resources/pam.d/sshd /etc/pam.d/sshd_cnfig

# Post-install setup: pip, rsyslog config, initctl shim, ansible inventory, cleanups
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir $pip_packages && \
    sed -i "s/^\(\$ModLoad imklog\)/#\1/" /etc/rsyslog.conf && \
    chmod +x /initctl-shim && ln -sf /initctl-shim /sbin/initctl && \
    mkdir -p /etc/ansible && \
    printf "[local]\nlocalhost ansible_connection=local\n" > /etc/ansible/hosts && \
    rm -f /lib/systemd/system/systemd*udev* && \
    rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
