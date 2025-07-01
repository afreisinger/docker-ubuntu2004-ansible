FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}

ARG pip_packages="ansible yamllint ansible-lint"

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
        freeradius-utils \
        gnupg \
        gnupg2 \
        parted \
        iproute2 \
        iputils-ping \
        libpam-radius-auth \
        locales \
        netcat \
        net-tools \
        openssh-server \
        pamtester \
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
    && rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* /tmp/* /var/tmp/*

# Copy certificates and update trust store
COPY certs/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Copy the initctl shim
COPY initctl-shim /initctl-shim

# Post-install setup: pip, rsyslog config, initctl shim, ansible inventory, cleanups
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir $pip_packages && \
    sed -i "s/^\(\$ModLoad imklog\)/#\1/" /etc/rsyslog.conf && \
    chmod +x /initctl-shim && ln -sf /initctl-shim /sbin/initctl && \
    mkdir -p /etc/ansible && \
    printf "[local]\nlocalhost ansible_connection=local\n" > /etc/ansible/hosts && \
    rm -f /lib/systemd/system/systemd*udev* /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
