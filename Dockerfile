FROM mcr.microsoft.com/azurelinux-beta/base/core:4.0

ENV DEBIAN_FRONTEND=noninteractive

# Cambiamos iptables por nftables
RUN tdnf update -y && tdnf install -y \
    openssh-server \
    openssh-clients \
    nftables \
    sudo \
    shadow-utils \
    iproute \
    && tdnf clean all

RUN mkdir -p /var/run/sshd
COPY scripts/hardening.sh /usr/local/bin/hardening.sh
RUN chmod +x /usr/local/bin/hardening.sh
EXPOSE 2222
RUN ssh-keygen -A

CMD ["/bin/bash", "-c", "/usr/local/bin/hardening.sh && exec /usr/sbin/sshd -D"]