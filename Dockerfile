FROM ubuntu:20.04
LABEL maintainer="Adrian Freisinger"

ARG DEBIAN_FRONTEND=noninteractive

# Establecer locales correctamente desde el principio
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 1. Actualizar e instalar locales + apt-utils antes de cualquier otra cosa
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    apt-utils && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# 2. Instalar el resto de dependencias
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    gnupg \
    sudo \
    rsyslog \
    systemd \
    systemd-cron \
    iproute2 \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-pip \
    libffi-dev \
    libssl-dev \
    libyaml-dev \
    ca-certificates \
    software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3. Actualizar pip e instalar paquetes Python necesarios
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
    ansible \
    yamllint \
    ansible-lint \
    'pyyaml>=5.4.1'

# 4. Instalar Node.js 18 y markdownlint-cli
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g markdownlint-cli

# 5. Instalar hadolint
RUN wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64 && \
    chmod +x /bin/hadolint

# 6. Deshabilitar imklog (rsyslog en contenedores)
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# 7. Fake de initctl
COPY initctl-shim /initctl-shim
RUN chmod +x /initctl-shim && ln -sf /initctl-shim /sbin/initctl

# 8. Configuración mínima de inventario Ansible
RUN mkdir -p /etc/ansible && \
    echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# 9. Remover servicios innecesarios que generan uso de CPU
RUN rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
