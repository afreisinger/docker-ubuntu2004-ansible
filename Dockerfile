FROM ubuntu:20.04
LABEL maintainer="Adrian Freisinger"

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV pip_packages="ansible"

# Install dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
       apt-utils \
       build-essential \
       locales \
       libffi-dev \
       libssl-dev \
       libyaml-dev \
       python3-dev \
       python3-setuptools \
       python3-pip \
       python3-yaml \
       software-properties-common \
       rsyslog \
       systemd \
       systemd-cron \
       sudo \
       iproute2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Deshabilitar imklog en rsyslog (evita errores en contenedores)
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Fix potential UTF-8 errors with ansible-test.
RUN locale-gen en_US.UTF-8

# Install Ansible via Pip.
RUN pip3 install --no-cache-dir $pip_packages

# Install Ansible inventory file.
COPY initctl-shim /initctl-shim
RUN chmod +x /initctl-shim && ln -sf /initctl-shim /sbin/initctl

# Configurar inventario Ansible
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Remove unnecessary getty and udev targets that result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
