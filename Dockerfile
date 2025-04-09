FROM ubuntu:20.04
LABEL maintainer="Adrián Freisinger"

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}

ARG pip_packages="ansible"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-utils \
        curl \
        sudo \
        rsyslog \
        systemd \
        python3 \
        python3-pip \
        ca-certificates \
        iputils-ping \
        dnsutils \
        net-tools \
        iproute2 \
        software-properties-common \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc && rm -rf /usr/share/man

RUN sed -i "s/^\(\$ModLoad imklog\)/#\1/" /etc/rsyslog.conf

COPY initctl-shim /initctl-shim
RUN chmod +x /initctl-shim && ln -sf /initctl-shim /sbin/initctl

RUN mkdir -p /etc/ansible && \
    printf "[local]\nlocalhost ansible_connection=local\n" > /etc/ansible/hosts && \
    rm -f /lib/systemd/system/systemd*udev* && \
    rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
